<?php
	class reports {
		private $working_days = array();

		function __construct ($smarty) {
			$this->smarty = $smarty;
		}

		function __destruct () {}


		function rep_timeslot () {
		 	if (!_base::CheckAccess('rep_timeslot')) return;
			$_SESSION['main_menu'] = 'reports';
			$_SESSION['sub_menu'] = 'rep_timeslot';
			$sub_menu = $_SESSION['sub_menu'];
			_base::readFilterToSESSION_new($sub_menu);
			$this->smarty->assign ('current_url', '/reports/rep_timeslot');

			if (!isset($_SESSION[$sub_menu]['from_date']) or !$_SESSION[$sub_menu]['from_date'])
				// Днешна дата
				$_SESSION[$sub_menu]['from_date'] = date('Y-m-d');

			if (!isset($_SESSION[$sub_menu]['w_group_id']))
				$_SESSION[$sub_menu]['w_group_id'] = $_SESSION['userdata']['w_group_id'];
			_base::get_select_list('w_group');
			
			_base::put_sys_oper(__METHOD__, 'browse', $sub_menu, 0);
		}

		function rep_timeslot_ajax () {
		 	if (!_base::CheckAccess('rep_timeslot')) return;
			_base::readFilterToSESSION_new('rep_timeslot');

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

			echo json_encode($data, JSON_UNESCAPED_UNICODE);
		}

		// Връща масив със заявените количества по слотове за подадения склад за подадената дата
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

		
		function rep_timeslot_shop () {
		 	if (!_base::CheckAccess('rep_timeslot_shop')) return;
			$_SESSION['main_menu'] = 'reports';
			$_SESSION['sub_menu'] = 'rep_timeslot_shop';
			$sub_menu = $_SESSION['sub_menu'];
			_base::readFilterToSESSION_new($sub_menu);
			$this->smarty->assign ('current_url', '/reports/rep_timeslot_shop');

			if (!isset($_SESSION[$sub_menu]['from_date']) or !$_SESSION[$sub_menu]['from_date'])
				// Днешна дата
				$_SESSION[$sub_menu]['from_date'] = date('Y-m-d');

			if (!isset($_SESSION[$sub_menu]['w_group_id']))
				$_SESSION[$sub_menu]['w_group_id'] = $_SESSION['userdata']['w_group_id'];
			_base::get_select_list('w_group');
			
			if (!isset($_SESSION[$sub_menu]['summarize']))
				$_SESSION[$sub_menu]['summarize'] = '1';

			_base::put_sys_oper(__METHOD__, 'browse', $sub_menu, 0);
		}

		function rep_timeslot_shop_ajax () {
		 	if (!_base::CheckAccess('rep_timeslot_shop')) return;
			_base::readFilterToSESSION_new('rep_timeslot_shop');

			if (!isset($_SESSION[$_SESSION['sub_menu']]['from_date']) or !$_SESSION[$_SESSION['sub_menu']]['from_date'])
				// Днешна дата
				$_SESSION[$_SESSION['sub_menu']]['from_date'] = date('Y-m-d');

			$curr_date = date('Y-m-d', strtotime($_SESSION[$_SESSION['sub_menu']]['from_date']. " - 1 day"));
			$w_group_id = intVal($_SESSION[$_SESSION['sub_menu']]['w_group_id']);
			$summarize = intVal($_SESSION[$_SESSION['sub_menu']]['summarize']);


			// Заетост на времевите слотове по дни за всяка платформа
			// [shop_id => [working_day => [timeslot => [бр.авиза, палети, колети, тегло, обем, сметнати палети] ] ]

			// Зареждаме работните дни в масива working_days
			$config_aviso_days_forecast = _base::get_config('config_aviso_days_forecast');
			if (!$config_aviso_days_forecast) $config_aviso_days_forecast = 5;
			$this->load_working_days($curr_date, $config_aviso_days_forecast);
			// Първия работен ден след предишния ден на посочената дата
			$from_date = $curr_date = $this->working_days[1];
			$to_date = $this->working_days[$config_aviso_days_forecast-1];

			$shop = _base::select_sql_multiline("select shop_id, shop_name from shop where is_active = '1' order by shop_name");
			$data = array();
			if ($shop)
				foreach($shop as $line) {
					for ($i = 1; $i < $config_aviso_days_forecast; $i++) {
						if ($summarize)
							$data[$this->working_days[$i]][$line['shop_name']] = $this->fill_timeslot_shop($line + array('for_date'=>$this->working_days[$i], 'w_group_id' => $w_group_id, 'summarize' => $summarize));
						else
							$data[$line['shop_name']][$this->working_days[$i]] = $this->fill_timeslot_shop($line + array('for_date'=>$this->working_days[$i], 'w_group_id' => $w_group_id, 'summarize' => $summarize));
					}
				}

			echo json_encode($data, JSON_UNESCAPED_UNICODE);
		}

		// Връща масив със заявените количества по слотове за подадения магазин за подадената дата
		// [ "09:00" => [бр.авиза, палети, колети, тегло, обем, сметнати палети], ... ]
		private function fill_timeslot_shop($array_param) {
			// w_group_id, shop_id, for_date
			$w_group_id = intVal($array_param['w_group_id']);
			$shop_id = intVal($array_param['shop_id']);
			$for_date = $array_param['for_date'];
			$summarize = intVal($array_param['summarize']);

			$result = array();
			$total = array('cnt_aviso'=>0,'qty_pallet'=>0,'qty_pack'=>0,'weight'=>0,'volume'=>0,'qty_pallet_calc'=>0);
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
				where aviso.aviso_date = '$for_date'" . PHP_EOL
				. ($w_group_id ? "and warehouse.w_group_id = $w_group_id" . PHP_EOL : '')
				."and aviso_line.shop_id = $shop_id
				group by aviso.aviso_time";
			$query_result = _base::get_query_result($sql_query);
			while ($query_data = _base::sql_fetch_assoc($query_result)) {
				if (!$summarize) {
					$curr_time = substr($query_data['aviso_time'], 0, 5);
					$result[$curr_time]['cnt_aviso'] = $query_data['cnt_aviso'];
					$result[$curr_time]['qty_pallet'] = $query_data['qty_pallet'];
					$result[$curr_time]['qty_pack'] = $query_data['qty_pack'];
					$result[$curr_time]['weight'] = $query_data['weight'];
					$result[$curr_time]['volume'] = $query_data['volume'];
					$result[$curr_time]['qty_pallet_calc'] = $query_data['qty_pallet_calc'];
				}

				$total['cnt_aviso'] += $query_data['cnt_aviso'];
				$total['qty_pallet'] += $query_data['qty_pallet'];
				$total['qty_pack'] += $query_data['qty_pack'];
				$total['weight'] += $query_data['weight'];
				$total['volume'] += $query_data['volume'];
				$total['qty_pallet_calc'] += $query_data['qty_pallet_calc'];
			}
			_base::sql_free_result($query_result);

			// Накрая един сумарен ред
			if (!$summarize)
				$result['----'] = $total;
			else
				$result = $total;

			
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


		function rep_plt_balans () {
		 	if (!_base::CheckAccess('rep_plt_balans')) return;

			$_SESSION['main_menu'] = 'reports';
			$_SESSION['sub_menu'] = 'rep_plt_balans';
			$sub_menu = $_SESSION['sub_menu'];
			_base::readFilterToSESSION_new($sub_menu);
			$this->smarty->assign('current_url', '/reports/rep_plt_balans');

			if (!isset($_SESSION[$sub_menu]['org_id']))
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];
			// Ако потребителя няма право да вижда всички Доставчици
			if (!$_SESSION['userdata']['grants']['view_all_suppliers'])
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];

			$config_plt_balans_date = _base::get_config('config_plt_balans_date');
			if (!isset($_SESSION[$sub_menu]['from_date']))
				$_SESSION[$sub_menu]['from_date'] = max(date('Y-m-d'), $config_plt_balans_date);
			$this->smarty->assign('config_plt_balans_date', $config_plt_balans_date);

			_base::get_select_list('org', null, 'org_name');

			_base::put_sys_oper(__METHOD__, 'browse', $sub_menu, 0);
		}

		function rep_plt_balans_ajax () {
		 	if (!_base::CheckAccess('rep_plt_balans')) return;

			$sub_menu = 'rep_plt_balans';
			_base::readFilterToSESSION_new($sub_menu);
			$where = "where (1=1)";
			$where_ns = "where (1=1)";

			if (!isset($_SESSION[$sub_menu]['org_id']))
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];
			// Ако потребителя няма право да вижда всички Доставчици
			if (!$_SESSION['userdata']['grants']['view_all_suppliers'])
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];

			$org_id = intVal($_SESSION[$sub_menu]['org_id']);
			if ($org_id)
				$where .= " and (org_id = $org_id)";

			$config_plt_balans_date = _base::get_config('config_plt_balans_date');

			$from_date = $_SESSION[$sub_menu]['from_date'];
			$to_date = $_SESSION[$sub_menu]['to_date'];
			if ($from_date < $config_plt_balans_date) {
				$_SESSION[$sub_menu]['from_date'] = $config_plt_balans_date;
				$from_date = $config_plt_balans_date;
			}
			if ($from_date)
				$where .= " and pltorg_date >= '$from_date'";
			if ($to_date)
				$where .= " and pltorg_date <= '$to_date'";

			if ($org_id)
				$where_ns .= " and (org_id = $org_id)";
			if ($config_plt_balans_date)
				$where_ns .= " and (pltorg_date >= '$config_plt_balans_date')";
			if ($from_date)
				$where_ns .= " and (pltorg_date < '$from_date')";

			$sql_query = " 
select sss.org_id, org.org_name,
ns_eur, in_eur, ret_eur, claim_eur, (ns_eur+in_eur-ret_eur-claim_eur) ks_eur,
ns_chep, in_chep, ret_chep, claim_chep, (ns_chep+in_chep-ret_chep-claim_chep) ks_chep,
ns_other, in_other, ret_other, claim_other, (ns_other+in_other-ret_other-claim_other) ks_other

from (
select ss.org_id,
sum(ns_eur) as ns_eur,
sum(ns_chep) as ns_chep,
sum(ns_other) as ns_other,

sum(in_eur) in_eur,
sum(ret_eur) ret_eur,
sum(claim_eur) claim_eur,

sum(in_chep) in_chep,
sum(ret_chep) ret_chep,
sum(claim_chep) claim_chep,

sum(in_other) in_other,
sum(ret_other) ret_other,
sum(claim_other) claim_other

from (
select org_id,
org_ns_plt_eur ns_eur,
org_ns_plt_chep ns_chep,
org_ns_plt_other ns_other,

0 as in_eur,
0 as ret_eur,
0 as claim_eur,

0 as in_chep,
0 as ret_chep,
0 as claim_chep,

0 as in_other,
0 as ret_other,
0 as claim_other

from org
where ((org_ns_plt_eur <> 0) or (org_ns_plt_chep <> 0) or (org_ns_plt_other <> 0))" . PHP_EOL
. ($org_id ? " and (org_id = $org_id)" : '') . PHP_EOL

. "union all

select org_id,
sum(qty_plt_eur-qty_ret_plt_eur-qty_claim_plt_eur) as ns_eur,
sum(qty_plt_chep-qty_ret_plt_chep-qty_claim_plt_chep) as ns_chep,
sum(qty_plt_other-qty_ret_plt_other-qty_claim_plt_other) as ns_other,

0 as in_eur,
0 as ret_eur,
0 as claim_eur,

0 as in_chep,
0 as ret_chep,
0 as claim_chep,

0 as in_other,
0 as ret_other,
0 as claim_other

from pltorg
$where_ns
group by org_id

union all

select org_id,
0 as ns_eur,
0 as ns_chep,
0 as ns_other,

sum(qty_plt_eur) in_eur,
sum(qty_ret_plt_eur) ret_eur,
sum(qty_claim_plt_eur) claim_eur,

sum(qty_plt_chep) in_chep,
sum(qty_ret_plt_chep) ret_chep,
sum(qty_claim_plt_chep) claim_chep,

sum(qty_plt_other) in_other,
sum(qty_ret_plt_other) ret_other,
sum(qty_claim_plt_other) claim_other

from pltorg
$where
group by org_id
) ss
group by ss.org_id
) sss
left join org on sss.org_id = org.org_id
order by org_name";

			_base::echo_nomen_list_partial($sql_query, 'org_id');
		}


		function rep_pltshop_balans () {
		 	if (!_base::CheckAccess('rep_pltshop_balans')) return;

			$_SESSION['main_menu'] = 'reports';
			$_SESSION['sub_menu'] = 'rep_pltshop_balans';
			$sub_menu = $_SESSION['sub_menu'];
			_base::readFilterToSESSION_new($sub_menu);
			$this->smarty->assign('current_url', '/reports/rep_pltshop_balans');

			if (!isset($_SESSION[$sub_menu]['from_date']))
				$_SESSION[$sub_menu]['from_date'] = date('Y-m-d');

			_base::get_select_list('shop', null, 'shop_name');

			_base::put_sys_oper(__METHOD__, 'browse', $sub_menu, 0);
		}

		function rep_pltshop_balans_ajax () {
		 	if (!_base::CheckAccess('rep_pltshop_balans')) return;

			$sub_menu = 'rep_pltshop_balans';
			_base::readFilterToSESSION_new($sub_menu);
			$where = "where (1=1)";
			$where_ns = "where (1=1)";

			$shop_id = intVal($_SESSION[$sub_menu]['shop_id']);
			if ($shop_id)
				$where .= " and (shop_id = $shop_id)";

			$from_date = $_SESSION[$sub_menu]['from_date'];
			$to_date = $_SESSION[$sub_menu]['to_date'];
			if ($from_date)
				$where .= " and pltshop_date >= '$from_date'";
			if ($to_date)
				$where .= " and pltshop_date <= '$to_date'";

			if ($shop_id)
				$where_ns .= " and (shop_id = $shop_id)";
			if ($from_date)
				$where_ns .= " and (pltshop_date < '$from_date')";

			$sql_query = " 
select sss.shop_id, shop.shop_name,
ns_eur, in_eur, ret_eur, claim_eur, (ns_eur+in_eur-ret_eur-claim_eur) ks_eur,
ns_chep, in_chep, ret_chep, claim_chep, (ns_chep+in_chep-ret_chep-claim_chep) ks_chep,
ns_other, in_other, ret_other, claim_other, (ns_other+in_other-ret_other-claim_other) ks_other

from (
select ss.shop_id,
sum(ns_eur) as ns_eur,
sum(ns_chep) as ns_chep,
sum(ns_other) as ns_other,

sum(in_eur) in_eur,
sum(ret_eur) ret_eur,
sum(claim_eur) claim_eur,

sum(in_chep) in_chep,
sum(ret_chep) ret_chep,
sum(claim_chep) claim_chep,

sum(in_other) in_other,
sum(ret_other) ret_other,
sum(claim_other) claim_other

from (
select shop_id,
sum(qty_plt_eur-qty_ret_plt_eur-qty_claim_plt_eur) as ns_eur,
sum(qty_plt_chep-qty_ret_plt_chep-qty_claim_plt_chep) as ns_chep,
sum(qty_plt_other-qty_ret_plt_other-qty_claim_plt_other) as ns_other,

0 as in_eur,
0 as ret_eur,
0 as claim_eur,

0 as in_chep,
0 as ret_chep,
0 as claim_chep,

0 as in_other,
0 as ret_other,
0 as claim_other

from pltshop
$where_ns
group by shop_id

union all

select shop_id,
0 as ns_eur,
0 as ns_chep,
0 as ns_other,

sum(qty_plt_eur) in_eur,
sum(qty_ret_plt_eur) ret_eur,
sum(qty_claim_plt_eur) claim_eur,

sum(qty_plt_chep) in_chep,
sum(qty_ret_plt_chep) ret_chep,
sum(qty_claim_plt_chep) claim_chep,

sum(qty_plt_other) in_other,
sum(qty_ret_plt_other) ret_other,
sum(qty_claim_plt_other) claim_other

from pltshop
$where
group by shop_id
) ss
group by ss.shop_id
) sss
left join shop on sss.shop_id = shop.shop_id
order by shop_name";

			_base::echo_nomen_list_partial($sql_query, 'shop_id');
		}

	}
?>
