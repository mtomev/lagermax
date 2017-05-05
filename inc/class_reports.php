<?php
	class reports {
		private $working_days = array();

		function __construct ($smarty) {
			$this->smarty = $smarty;
		}

		function __destruct () {}


		function timeslot () {
		 	if (!_base::CheckAccess('aviso')) return;
			$_SESSION['main_menu'] = 'reports';
			$_SESSION['sub_menu'] = 'timeslot';
			$sub_menu = $_SESSION['sub_menu'];
			_base::readFilterToSESSION_new($sub_menu);
			$this->smarty->assign ('current_url', '/reports/timeslot');

			if (!isset($_SESSION[$sub_menu]['from_date']) or !$_SESSION[$sub_menu]['from_date'])
				// Днешна дата
				$_SESSION[$sub_menu]['from_date'] = date('Y-m-d');

			if (!isset($_SESSION[$sub_menu]['w_group_id']))
				$_SESSION[$sub_menu]['w_group_id'] = $_SESSION['userdata']['w_group_id'];
			_base::get_select_list('w_group');
			
			_base::put_sys_oper(__METHOD__, 'browse', $sub_menu, 0);
		}

		// Тази функция се вика само като ajax
		function get_timeslot () {
			_base::readFilterToSESSION_new('timeslot');

			$where_warehouse = "where is_active = '1'";
			if ($_SESSION[$_SESSION['sub_menu']]['w_group_id']) {
				$where_warehouse .= ' and (w_group_id = '.intVal($_SESSION[$_SESSION['sub_menu']]['w_group_id']).')';
			}

			if (!isset($_SESSION[$_SESSION['sub_menu']]['from_date']) or !$_SESSION[$_SESSION['sub_menu']]['from_date'])
				// Днешна дата
				$_SESSION[$_SESSION['sub_menu']]['from_date'] = date('Y-m-d');

			$curr_date = date('Y-m-d', strtotime($_SESSION[$_SESSION['sub_menu']]['from_date']. " - 1 day"));


			// Заетост на времевите слотове по дни за всяка платформа
			// [warehouse_id => [working_day => [timeslot => [бр.авиза, палети, колети, тегло, обем, сметнати палети] ] ]

			// Зареждаме работните дни в масива working_days
			$config_aviso_days_forecast = _base::get_config('config_aviso_days_forecast');
			if (!$config_aviso_days_forecast) $config_aviso_days_forecast = 5;
			$this->load_working_days($curr_date, $config_aviso_days_forecast);
			// Първия работен ден след предишния ден на посочената дата
			$from_date = $curr_date = $this->working_days[1];
			$to_date = $this->working_days[$config_aviso_days_forecast-1];

			$warehouse = _base::select_sql_multiline("select warehouse_id, warehouse_code, w_start_time, w_end_time, w_interval, w_max_pallet from warehouse $where_warehouse order by warehouse_code");
			$data = array();
			if ($warehouse)
				foreach($warehouse as $line) {
					for ($i = 1; $i < $config_aviso_days_forecast; $i++) {
						$data[$line['warehouse_code']][$this->working_days[$i]] = $this->fill_timeslot($line + array('for_date'=>$this->working_days[$i]));
					}
				}

//print nl2br2 (print_r($this->working_days, true) . PHP_EOL);
			echo json_encode($data, JSON_UNESCAPED_UNICODE);
		}


		// Връща масив със списъка от свободни слотове за подадения склад за подадената дата
		// [ "09:00" => [бр.авиза, палети, колети, тегло, обем, сметнати палети], ... ]
		private function fill_timeslot($array_param) {
			$warehouse_id = intVal($array_param['warehouse_id']);
			$for_date = $array_param['for_date'];

			// w_start_time - w_end_time, w_interval, w_count, w_max_pallet
			$result = array();
			if (!$array_param['w_interval']) return $result;
			
			$curr_time = strtotime($array_param['w_start_time']);
			$w_end_time = strtotime($array_param['w_end_time']);
			$w_interval = intVal($array_param['w_interval']) * 60;
			while ($curr_time <= $w_end_time) {
				$result[date('H:i', $curr_time)] = array('cnt_aviso'=>0,'qty_pallet'=>0,'qty_pack'=>0,'weight'=>0,'volume'=>0,'qty_pallet_calc'=>0);
				$curr_time = $curr_time + $w_interval;
			}
			// Накрая един сумарен ред
			$total_index = '----';
			$result[$total_index] = array('cnt_aviso'=>0,'qty_pallet'=>0,'qty_pack'=>0,'weight'=>0,'volume'=>0,'qty_pallet_calc'=>0);
			
			// Какви заявки вече има за склада и датата
			$sql_query = "select aviso.aviso_time, count(distinct aviso.aviso_id) cnt_aviso,
				sum(aviso_line.qty_pallet) qty_pallet,
				sum(aviso_line.qty_pack) qty_pack,
				sum(aviso_line.weight) weight,
				sum(aviso_line.volume) volume,
				sum(aviso_line.qty_pallet)+(sum(aviso_line.qty_pack/warehouse.w_pack2pallet)) qty_pallet_calc
				from aviso
				left outer join warehouse on aviso.warehouse_id = warehouse.warehouse_id
				left outer join aviso_line on aviso_line.aviso_id = aviso.aviso_id
				where aviso.warehouse_id = $warehouse_id
				and aviso.aviso_date = '$for_date'
				group by aviso.aviso_time";
			$query_result = _base::get_query_result($sql_query);
			while ($query_data = _base::sql_fetch_assoc($query_result)) {
				$curr_time = substr($query_data['aviso_time'], 0, 5);
				$result[$curr_time]['cnt_aviso'] += $query_data['cnt_aviso'];
				$result[$curr_time]['qty_pallet'] += $query_data['qty_pallet'];
				$result[$curr_time]['qty_pack'] += $query_data['qty_pack'];
				$result[$curr_time]['weight'] += $query_data['weight'];
				$result[$curr_time]['volume'] += $query_data['volume'];
				$result[$curr_time]['qty_pallet_calc'] += $query_data['qty_pallet_calc'];

				$result[$total_index]['cnt_aviso'] += $query_data['cnt_aviso'];
				$result[$total_index]['qty_pallet'] += $query_data['qty_pallet'];
				$result[$total_index]['qty_pack'] += $query_data['qty_pack'];
				$result[$total_index]['weight'] += $query_data['weight'];
				$result[$total_index]['volume'] += $query_data['volume'];
				$result[$total_index]['qty_pallet_calc'] += $query_data['qty_pallet_calc'];
			}
			_base::sql_free_result($query_result);

			
			return $result;
		}

		// Зареждане на $config_aviso_days_forecast+2 работни дни след $date в масива working_days
		private function load_working_days($date, $config_aviso_days_forecast) {
			// От таблицата calendar трябва да изчетем работни/почивни дни след $date
			$sql_query = "select calendar_date, calendar_is_working_day from calendar where calendar_date > '$date'";
			$query_result = _base::get_query_result($sql_query);
			$calendar_date = array();
			while ($query_data =  _base::sql_fetch_row($query_result)) {
				$calendar_date[$query_data[0]] = $query_data[1];
			}
			_base::sql_free_result($query_result);

			// working_days[0] = $date, ..., working_days[$config_aviso_days_forecast] = ''
			$this->working_days[0] = $date;
			//set_time_limit(5);
			for ($i = 1; $i <= $config_aviso_days_forecast+2; $i++) {
				$this->working_days[$i] = date('Y-m-d', strtotime($this->working_days[$i-1]. " + 1 day"));
				while (true) {
					$week_day = date('w', strtotime($this->working_days[$i]));

					// 1-5-понеделник-петък и не е означен като почивен, ОК
					//if ($week_day >= 1 and $week_day <= 5 and (!array_key_exists($this->working_days[$i], $calendar_date) or $calendar_date[$this->working_days[$i]] !== '2'))
					if ($week_day >= 1 and $week_day <= 5 and $calendar_date[$this->working_days[$i]] !== '2')
						break;
					// 6-събота или 0-неделя и е работен, ОК
					//if (($week_day == 6 or $week_day == 0) and array_key_exists($this->working_days[$i], $calendar_date) and $calendar_date[$this->working_days[$i]] === '1')
					if (($week_day == 6 or $week_day == 0) and $calendar_date[$this->working_days[$i]] === '1')
						break;
					$this->working_days[$i] = date('Y-m-d', strtotime($this->working_days[$i]. " + 1 day"));
				}
			}
		}
		// Връща следващия $days работен ден след $date във формат '2017-02-25'
		private function next_working_day($date, $days) {
			// Преди първо извикване, да се заредят във масива working_days
			$index = array_search($date, $this->working_days);
			return $this->working_days[$index + $days];
		}


	}
?>
