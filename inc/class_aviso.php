<?php
	require_once(COMPS_DIR.'/fpdf181/code128.php');
	class aviso_PDF extends PDF_Code128 {
		public $footers = array();
		// Page header
		function Header() {
			/*
			// Logo
			$this->Image('logo.png',10,6,30);
			// Arial bold 15
			$this->SetFont('Arial','B',15);
			// Move to the right
			$this->Cell(80);
			// Title
			$this->Cell(30,10,'Title',1,0,'C');
			// Line break
			$this->Ln(20);
			*/
		}

		// Page footer
		function Footer() {
			/*
			$this->SetY(-20);
			$this->SetFont('Arial','',8);
			//$this->Cell(0,10,'Page '.$this->PageNo().'/{nb}',0,0,'C');
			foreach($this->footers as $footer)
				$this->Cell(0,3, iconv('UTF-8', 'windows-1252', $footer), 0, 1, 'C');
			*/
		}
	}

	class aviso {
		private $working_days = array();

		function __construct ($smarty) {
			$this->smarty = $smarty;
		}

		function __destruct () {}


		function aviso ($where_add = '') {
		 	if (!_base::CheckAccess('aviso')) return;
			$_SESSION['main_menu'] = 'aviso';
			$_SESSION['sub_menu'] = 'aviso';
			$sub_menu = $_SESSION['sub_menu'];
			_base::readFilterToSESSION_new($sub_menu);
			$this->smarty->assign ('current_url', '/aviso/aviso');

			// Запомням в $_SESSION where_add
			$_SESSION[$sub_menu]['where_add'] = $where_add;

			if (!isset($_SESSION[$sub_menu]['org_id']))
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];
			// Ако потребителя няма право да вижда всички Доставчици
			if (!$_SESSION['userdata']['grants']['view_all_suppliers'])
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];

			if (!isset($_SESSION[$sub_menu]['from_date']))
				// Днешна дата - 7 дни
				//$_SESSION[$sub_menu]['from_date'] = date('Y-m-d', strtotime(date("Y-m-d"). ' - 7 days'));
				$_SESSION[$sub_menu]['from_date'] = date('Y-m-d');

			_base::get_select_list('org', null, 'org_name');

			_base::set_table_edit_AccessRights('aviso');
			// Ако е подадено $where_add, то от съответната функция ще се запише в базата
			if (!$where_add)
				_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
		}

		// Тази функция се вика само като ajax
		function get_list_aviso () {
			$sub_menu = 'aviso';
			_base::readFilterToSESSION_new($sub_menu);
			$where = "WHERE (1=1)";

			if (!isset($_SESSION[$sub_menu]['org_id']))
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];
			// Ако потребителя няма право да вижда всички Доставчици
			if (!$_SESSION['userdata']['grants']['view_all_suppliers'])
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];
			
			if ($_SESSION[$sub_menu]['org_id'])
				$where .= " and (org_id = {$_SESSION[$sub_menu]['org_id']})";

			$from_date = $_SESSION[$sub_menu]['from_date'];
			$to_date = $_SESSION[$sub_menu]['to_date'];
			if ($from_date)
				$where .= " and aviso_date >= '$from_date'";
			if ($to_date)
				$where .= " and aviso_date <= '$to_date'";

			// Ако е извикано от подменютата за Инвестиционни или Оперативни разходи
			if ($_SESSION[$sub_menu]['where_add'])
				$where .= $_SESSION[$sub_menu]['where_add'];

			$data = _base::nomen_list('aviso', true, 'aviso_id', $where);
			echo json_encode(array('data' => $data));
		}


		function aviso_detail ($where_add = '') {
		 	if (!_base::CheckAccess('aviso')) return;
			$_SESSION['main_menu'] = 'aviso';
			$_SESSION['sub_menu'] = 'aviso_detail';
			$sub_menu = $_SESSION['sub_menu'];
			_base::readFilterToSESSION_new($sub_menu);
			$this->smarty->assign ('current_url', '/aviso/aviso_detail');

			// Запомням в $_SESSION where_add
			$_SESSION[$sub_menu]['where_add'] = $where_add;

			if (!isset($_SESSION[$sub_menu]['org_id']))
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];
			// Ако потребителя няма право да вижда всички Доставчици
			if (!$_SESSION['userdata']['grants']['view_all_suppliers'])
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];

			if (!isset($_SESSION[$sub_menu]['from_date']))
				$_SESSION[$sub_menu]['from_date'] = date('Y-m-d');
			if (!isset($_SESSION[$sub_menu]['to_date']))
				$_SESSION[$sub_menu]['to_date'] = date('Y-m-d');

			if (!isset($_SESSION[$sub_menu]['aviso_status']))
				//$_SESSION[$sub_menu]['aviso_status'] = '37';
				$_SESSION[$sub_menu]['aviso_status'] = -1;

			_base::get_select_list('org', null, 'org_name');
			_base::get_select_list('warehouse', null, 'warehouse_code', null, 'warehouse_code');
			_base::get_select_aviso_status();

			_base::set_table_edit_AccessRights('aviso');
			// Ако е подадено $where_add, то от съответната функция ще се запише в базата
			if (!$where_add)
				_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
		}

		// Тази функция се вика само като ajax
		function get_list_aviso_detail () {
			$sub_menu = 'aviso_detail';
			_base::readFilterToSESSION_new($sub_menu);
			$where = "WHERE (1=1)";

			if ($_SESSION[$sub_menu]['warehouse_id'])
				$where .= " and (warehouse_id = {$_SESSION[$sub_menu]['warehouse_id']})";
			if ($_SESSION[$sub_menu]['org_id'])
				$where .= " and (org_id = {$_SESSION[$sub_menu]['org_id']})";

			$from_date = $_SESSION[$sub_menu]['from_date'];
			$to_date = $_SESSION[$sub_menu]['to_date'];
			if ($from_date)
				$where .= " and aviso_date >= '$from_date'";
			if ($to_date)
				$where .= " and aviso_date <= '$to_date'";

			if ($_SESSION[$sub_menu]['aviso_status'] != -1) {
				if ($_SESSION[$sub_menu]['aviso_status'] != '37')
					$where .= " and (aviso_status = '{$_SESSION[$sub_menu]['aviso_status']}')";
				else
					$where .= " and (aviso_status in ('3','7'))";
			}

			// Ако е извикано от подменютата за Инвестиционни или Оперативни разходи
			if ($_SESSION[$sub_menu]['where_add'])
				$where .= $_SESSION[$sub_menu]['where_add'];

			$sql_query = "select view_aviso_detail.*
				from view_aviso_detail 
				$where";
			$query_result = _base::get_query_result($sql_query);
			$data = array();
			while ($query_data = _base::sql_fetch_assoc($query_result, true)) {
				$data[] = $query_data + array('id' => $query_data['aviso_id'].'-'.$query_data['aviso_line_id']);
			}
			_base::sql_free_result($query_result);
			//echo json_encode($data);
			// Ако в aviso_detail.tpl се обработва през dataSrc, няма нужда да се прави с 'data' =>.
			echo json_encode(array('data' => $data));
		}


		function aviso_select_warehouse () {
		 	if (!_base::CheckAccess('aviso_add')) return;
			// Избор на Склад

			$data['allow_delete'] = false;
			$data['warehouse_id'] = $_SESSION['userdata']['warehouse_id'];
			$data['w_group_id'] = $_SESSION['userdata']['w_group_id'];

			// Списъци за избор
			_base::get_select_list('w_group', null, null, "where is_active = '1'");
			_base::get_select_list('warehouse', null, null, "where is_active = '1' and w_group_id = ".intVal($data['w_group_id']));


			$this->smarty->assign('data', $data);
		}

		// Тази функция се вика само като ajax, след смяна на w_group_id, за да даде списъка от warehouse за избрания w_group_id
		function get_w_group_id_warehouse () {
			// w_group_id
			$id = intVal($_REQUEST['p1']);

			$data = _base::get_select_list_ajax('warehouse', 'warehouse_name', "where w_group_id = $id");

			echo json_encode($data);
		}



		function aviso_edit () {
			// aviso_id / warehouse_id
			$id = intVal($_REQUEST['p1']);
			$warehouse_id = intVal($_REQUEST['p2']);

			$data = _base::nomen_list_edit('aviso', $id, true, null, $add_select);
			
			// С какъв интерфейс се редактира
			if (!$id) {
				// Ако е ново Авизо
				if (!_base::CheckAccess('aviso_add')) return;
				$data['warehouse_id'] = $warehouse_id;
				// Дефиницията на склада
				$warehouse = _base::select_sql("select * from warehouse where warehouse_id = $warehouse_id");
				$data['warehouse_template'] = $warehouse['warehouse_template'];
				$data['w_pack2pallet'] = $warehouse['w_pack2pallet'];
				$data['warehouse_type'] = $warehouse['warehouse_type'];

				if (intVal($_SESSION['userdata']['org_id']))
					$data['org_id'] = $_SESSION['userdata']['org_id'];
				else
					// Ако потребителя не е към някой Доставчик, то да вземем Доставчика от параметъра за справката
					$data['org_id'] = $_SESSION['aviso']['org_id'];
				$data['aviso_truck_type'] = '0';
				$data['aviso_status'] = '0';

				$data['aviso_driver_name'] = $_SESSION['userdata']['aviso_driver_name'];
				$data['aviso_driver_phone'] = $_SESSION['userdata']['aviso_driver_phone'];
			}
			else {
				// Ако е корекция на старо Авизо
				if (!_base::CheckGrant('aviso_view'))
					if (!_base::CheckAccess('aviso_edit')) return;
				$warehouse_id = intVal($data['warehouse_id']);

				// Ако потребител към някой доставчик, без право да вижда всички доставчици, се опитва да отвори неправомерно друго Авизо
				if (intVal($_SESSION['userdata']['org_id']) and $data['org_id'] != $_SESSION['userdata']['org_id'] and !$_SESSION['userdata']['grants']['view_all_suppliers']) {
					$_SESSION['display_path'] = 'main_menu/deflt.tpl';
					$_SESSION['display_text'] = $this->smarty->getConfigVars('access_denied');
					return;
				}

				// Ако Авизото е старо и потребителя няма право view_all_suppliers "Достъп до всички Доставчици", да не може да го записва
				if (!$_SESSION['userdata']['grants']['view_all_suppliers']) {
					// Ако текущия час е > от config_aviso_until_time, то започваме от по-следващия работен ден
					$config_aviso_until_time = _base::get_config('config_aviso_until_time');
					if (!$config_aviso_until_time) $config_aviso_until_time = '17:00';
					if (strtotime($config_aviso_until_time) <= strtotime(date("H:i")))
						$days = 2;
					else
						$days = 1;
					// Зареждаме работните дни в масива working_days
					$this->load_working_days(date("Y-m-d"), 2);
					$curr_date = $this->next_working_day(date("Y-m-d"), $days);
					
					if ($curr_date > $data['aviso_date']) {
						$data['allow_delete'] = false;
						$data['allow_edit'] = false;
					}
				}
			}
			$warehouse_template = $data['warehouse_template'];
			$_SESSION['display_path'] = "aviso/aviso_edit_".$warehouse_template.".tpl";

			$this->smarty->assign ('data', $data);


			// Редовете от Авизото
			$max_line_id = 0;
			$data_line = array();
			$query_result = _base::get_query_result("select * from view_aviso_line WHERE aviso_id = $id order by aviso_line_id");
			while ($query_data = _base::sql_fetch_assoc($query_result)) {
				$data_line[] = $query_data + array('id' => $query_data['aviso_line_id'], 'real_id' => $query_data['aviso_line_id']);
				if ($max_line_id < $query_data['aviso_line_id'])
					$max_line_id = $query_data['aviso_line_id'];
			}
			_base::sql_free_result($query_result);
			$this->smarty->assign ('data_line', json_encode($data_line));
			$this->smarty->assign ('max_line_id', $max_line_id);

			// Един празен ред като Object ( JSON )
			$query_result = _base::get_query_result("select * from view_aviso_line where 1=0");
			$empty_line = _base::sql_get_empty_assoc($query_result);

			_base::sql_add_field_width($query_result, $empty_line);
			_base::sql_free_result($query_result);
			$this->smarty->assign('empty_line', json_encode($empty_line));



			_base::get_select_list('warehouse');

			_base::get_select_list('org', null, 'org_name');
			// Списъка от Метро кодовете на този Контрагент
			//$this->smarty->assign('select_org_metro', json_encode(_base::get_select_org_metro(intVal($data['org_id']))));
			$this->smarty->assign('select_org_metro', json_encode(_base::get_select_list_ajax('org_metro', 'org_metro_code', 'where org_id = '.intVal($data['org_id']), 'org_metro_code', 'org_metro_code')));

			// get_select_list_ajax($table, $order_by = null, $where = null, $field_name = null, $field_id = null, $add_select = null)
			$this->smarty->assign('select_shop', json_encode(_base::get_select_list_ajax('shop', 'shop_name', "where is_active = '1'", 'shop_name')));

			$this->smarty->assign ('callback_url', "$_SERVER[HTTP_REFERER]");

			$_SESSION['aviso_id'] = $id;
			$_SESSION['table_edit'] = 'aviso';
			_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['table_edit'], $id);
		}

		function aviso_save () {
			// aviso_id
			$id = intVal($_REQUEST['p1']);

			if (!$id) {
				if (!_base::CheckAccess('aviso_add', false)) return;
			} else {
				if (!_base::CheckAccess('aviso_edit', false)) return;
			}
			
			// Проверки за неправомерност
			// Ако потребителя е с фиксиран org_id, проверка дали това Авизо е на същия org_id
			if (!$_SESSION['userdata']['grants']['view_all_suppliers'] and $_SESSION['userdata']['org_id']) {
				if (!$id)
					$temp = _base::select_sql("select org_id from aviso WHERE aviso_id = $id");
				else
					$temp['org_id'] = $_POST['org_id'];
				if ($temp['org_id'] != $_SESSION['userdata']['org_id'])
					_base::show_error($this->smarty->getConfigVars('access_denied'));
			}


			$_POST['aviso_date'] = $_POST['aviso_date_timeslot'];
			$_POST['aviso_time'] = $_POST['aviso_time_timeslot'];
			
			_base::start_transaction();

			$query = new ExecQuery('aviso');
			$query->AddParam('org_id', 'n', 0);
			$query->AddParam('warehouse_id', 'n', 0);

			$query->AddParam('aviso_truck_no');
			$query->AddParam('aviso_driver_name');
			$query->AddParam('aviso_driver_phone');
			$query->AddParam('aviso_truck_type', 'c');
			$query->AddParam('aviso_status', 'c');

			$query->AddParam('aviso_date', 'd');
			$query->AddParam('aviso_time', 't');

			if ($id != 0) {
				$query->update(["aviso_id" => $id]);
			}
			else {
				$id = $query->insert();
			}
			$_SESSION['aviso_id'] = $id;


			// Изтриване от aviso_line
			// Ако няма никакви редове, то deleted_line е празно
			$deleted_line = $_POST['deleted_line'];
			if ($deleted_line) {
				// deleted_line - array['aviso_line_id' => aviso_line_id]
				$deleted_line = json_decode($deleted_line, true);
				foreach($deleted_line as $aviso_line_id) {
					$sql_query = "DELETE FROM aviso_line WHERE (aviso_id = $id) and (aviso_line_id = $aviso_line_id)";
					_base::execute_sql($sql_query);
				}
			}

			// Запис в aviso_line
			$data_line = $_POST['data_line'];
			if ($data_line) {
				// data_line - array['aviso_line_id' => array[<field_name> => <value>]]
				$data_line = json_decode($data_line, true);
				foreach($data_line as $aviso_line_id => $line) {
					// AddParam ще добави параметъра, само ако е го има в масива
					$query = new ExecQuery('aviso_line');
					$query->a_get_values = $line;
					$query->add_cr_mo = false;
					$query->generator_name = false;
					$query->AddParamExt('aviso_id', $id, 'n', 0);
					$query->AddParam('aviso_line_id', 'n', 0);

					$query->AddParam('org_metro_code');
					$query->AddParam('metro_request_no');
					$query->AddParam('shop_id', 'n', 0);

					$query->AddParam('qty_pallet', 'n', 0);
					$query->AddParam('qty_pack', 'n', 0);
					$query->AddParam('weight', 'n', 0);
					$query->AddParam('volume', 'n', 0);

					// Ако line['real_id'] == '0', то е нов ред
					if ($line['real_id'])
						$query->update(["aviso_id" => $id, "aviso_line_id" => $aviso_line_id]);
					else
						$query->insert();
					unset($query);
				}
			} // data_line

			_base::commit_transaction();
			_base::put_sys_oper(__METHOD__, 'save', $_SESSION['table_edit'], $id);
			echo $id;
		}

		function aviso_delete () {
		 	if (!_base::CheckAccess('aviso_delete')) return;

			// aviso_id
			$id = intval($_REQUEST['p1']);

			if ($_POST{'process'} == 'delete' && $id) {
				// Ако потребителя е с фиксиран org_id, проверка дали това Авизо е на същия org_id
				if (!$_SESSION['userdata']['grants']['view_all_suppliers'] and $_SESSION['userdata']['org_id']) {
					$temp = _base::select_sql("select org_id from aviso WHERE aviso_id = $id");
					if ($temp['org_id'] != $_SESSION['userdata']['org_id'])
						_base::show_error($this->smarty->getConfigVars('access_denied'));
				}

				$sql_query = "DELETE FROM aviso WHERE aviso_id = $id";
				_base::execute_sql($sql_query);

				$sql_query = "DELETE FROM aviso_line WHERE aviso_id = $id";
				_base::execute_sql($sql_query);

				unset($_SESSION{'aviso_id'});
				_base::put_sys_oper(__METHOD__, 'delete', $_SESSION['table_edit'], $id);
			}
		}


		function aviso_select_timeslot () {
			// aviso_id
			$id = intVal($_REQUEST['p1']);

			// Ако текущия час е > от config_aviso_until_time, то започваме от по-следващия работен ден
			$config_aviso_until_time = _base::get_config('config_aviso_until_time');
			if (!$config_aviso_until_time) $config_aviso_until_time = '17:00';
			if (strtotime($config_aviso_until_time) <= strtotime(date("H:i")))
				$days = 2;
			else
				$days = 1;
			$config_aviso_days_forecast = _base::get_config('config_aviso_days_forecast');
			if (!$config_aviso_days_forecast) $config_aviso_days_forecast = 5;

			// Зареждаме работните дни в масива working_days
			$this->load_working_days(date("Y-m-d"), $config_aviso_days_forecast);

			if (!$id) {
				// Ако е ново Авизо
				if (!_base::CheckAccess('aviso_add')) return;

				// select_aviso_date
				$select_aviso_date[0] = '';

				$curr_date = $this->next_working_day(date("Y-m-d"), $days);

				// По подразбиране утрешна дата
				$_POST['aviso_date'] = $curr_date;
				$select_aviso_date[$curr_date] = _base::MySqlDate2Str($curr_date);

				// Да се добавят още config_aviso_days_forecast дни
				for ($i = 2; $i <= $config_aviso_days_forecast; $i++) {
					$curr_date = $this->next_working_day($curr_date, 1);
					$select_aviso_date[$curr_date] = _base::MySqlDate2Str($curr_date);
				}

				// select_aviso_time
				$select_aviso_time = $this->free_timeslot($_POST);
			}
			else {
				// Ако е корекция на старо Авизо
				if (!_base::CheckGrant('aviso_view'))
					if (!_base::CheckAccess('aviso_edit')) return;

				// select_aviso_date
				$select_aviso_date[0] = '';
				$curr_date = $_POST['aviso_date'];
				$select_aviso_date[$curr_date] = _base::MySqlDate2Str($curr_date);

				$curr_date = $this->next_working_day(date("Y-m-d"), $days);

				// Да се добавят още config_aviso_days_forecast дни
				for ($i = 1; $i <= $config_aviso_days_forecast; $i++) {
					$select_aviso_date[$curr_date] = _base::MySqlDate2Str($curr_date);
					$curr_date = $this->next_working_day($curr_date, 1);
				}
				ksort($select_aviso_date);

				// select_aviso_time
				$select_aviso_time = $this->free_timeslot($_POST);
				/*
				if (!array_key_exists($_POST['aviso_time'], $select_aviso_time))
					$select_aviso_time[$_POST['aviso_time']] = $_POST['aviso_time'];
				ksort($select_aviso_time);
				*/
			}

			$_POST['id'] = $id;
			$this->smarty->assign ('data', $_POST);
			$this->smarty->assign('select_aviso_date', $select_aviso_date);
			$this->smarty->assign('select_aviso_time', $select_aviso_time);
			$this->smarty->assign('working_days', $this->working_days);
		}

		// Тази функция се вика само като ajax, след смяна на Авизо Дата, за да даде свободните слотове за новата дата
		function get_aviso_timeslot () {
			// aviso_id
			$id = intVal($_REQUEST['p1']);

			$select_aviso_time = $this->free_timeslot($_POST);
			/*
			if ($id) {
				// Ако е корекция на старо Авизо
				if (!array_key_exists($_POST['aviso_time'], $select_aviso_time))
					$select_aviso_time[$_POST['aviso_time']] = $_POST['aviso_time'];
			}
			ksort($select_aviso_time);
			*/

			echo json_encode($select_aviso_time);
		}


		// Връща масив със списъка от свободни слотове за подадения склад за подадената дата
		// [ "09:00" => "09:00", "10:45" => "10:45", ... ]
		private function free_timeslot($array_param) {
			$aviso_id = intVal($array_param['aviso_id']);
			$warehouse_id = intVal($array_param['warehouse_id']);
			$aviso_date = $array_param['aviso_date'];
			$warehouse_type = $array_param['warehouse_type'];
			$qty_pallet_calc = $array_param['qty_pallet_calc'];

			// Дефиницията на склада
			$warehouse = _base::select_sql("select * from warehouse where warehouse_id = $warehouse_id");
			// w_start_time - w_end_time, w_interval, w_count, w_max_pallet
			$result[0] = '';
			if (!$warehouse['w_interval']) return $result;
			
			// Само от утрешна дата нататък може да се променя часовия слот
			if ($aviso_date <= date("Y-m-d")) return $result;

			$curr_time = strtotime($warehouse['w_start_time']);
			$w_end_time = strtotime($warehouse['w_end_time']);
			$w_interval = intVal($warehouse['w_interval']) * 60;
			while ($curr_time <= $w_end_time) {
				$result[date('H:i', $curr_time)] = floatVal($warehouse['w_max_pallet']);
				$curr_time = $curr_time + $w_interval;
			}
			
			// Какви заявки вече има за склада и датата
			$sql_query = "select aviso.aviso_time, count(distinct aviso.aviso_id) cnt_aviso, sum(qty_pallet)+(sum(qty_pack/warehouse.w_pack2pallet)) qty_pallet_calc
				from aviso
				left outer join warehouse on aviso.warehouse_id = warehouse.warehouse_id
				left outer join aviso_line on aviso_line.aviso_id = aviso.aviso_id
				where aviso.warehouse_id = $warehouse_id
				and aviso.aviso_date = '$aviso_date'
				and aviso.aviso_id <> $aviso_id
				group by aviso.aviso_time";
			$query_result = _base::get_query_result($sql_query);
			while ($query_data = _base::sql_fetch_assoc($query_result)) {
				$curr_time = substr($query_data['aviso_time'], 0, 5);
				$result[$curr_time] -= $query_data['qty_pallet_calc'];
			}
			_base::sql_free_result($query_result);
			
			// Да направим масива за избор
			foreach($result as $curr_time => $value) {
				if (!$curr_time)
					;
				else
				if ($result[$curr_time]-$qty_pallet_calc <= 0)
					unset($result[$curr_time]);
				else
					$result[$curr_time] = $curr_time . ' / ' . $result[$curr_time];
			}
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
		// Връща следващия $days работен ден след $date '2017-02-25'
		private function next_working_day($date, $days) {
			// Преди първо извикване, да се заредят във масива working_days
			$index = array_search($date, $this->working_days);
			return $this->working_days[$index + $days];
		}


		function aviso_reception ($where_add = '') {
		 	if (!_base::CheckAccess('aviso_reception')) return;
			$_SESSION['main_menu'] = 'aviso_reception';
			$_SESSION['sub_menu'] = 'aviso_reception';
			$sub_menu = $_SESSION['sub_menu'];
			_base::readFilterToSESSION_new($sub_menu);
			$this->smarty->assign ('current_url', '/aviso/aviso_reception');

			// Запомням в $_SESSION where_add
			$_SESSION[$sub_menu]['where_add'] = $where_add;

			/*
			_base::get_select_list('org', null, 'org_name');
			if (!isset($_SESSION[$sub_menu]['org_id']))
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];
			// Ако потребителя няма право да вижда всички Доставчици
			if (!$_SESSION['userdata']['grants']['view_all_suppliers'])
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];
			*/

			if (!isset($_SESSION[$sub_menu]['from_date']))
				// Днешна дата - 7 дни
				//$_SESSION[$sub_menu]['from_date'] = date('Y-m-d', strtotime(date("Y-m-d"). ' - 7 days'));
				$_SESSION[$sub_menu]['from_date'] = date('Y-m-d');

			_base::get_select_aviso_status();
			if (!isset($_SESSION[$sub_menu]['aviso_status']))
				$_SESSION[$sub_menu]['aviso_status'] = '03';
				//$_SESSION[$sub_menu]['aviso_status'] = -1;

			_base::set_table_edit_AccessRights('aviso');
			// Ако е подадено $where_add, то от съответната функция ще се запише в базата
			if (!$where_add)
				_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
		}

		// Тази функция се вика само като ajax
		function get_list_aviso_reception () {
			$sub_menu = 'aviso_reception';
			_base::readFilterToSESSION_new($sub_menu);
			$where = "WHERE (1=1)";

			/*
			if (!isset($_SESSION[$sub_menu]['org_id']))
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];
			// Ако потребителя няма право да вижда всички Доставчици
			if (!$_SESSION['userdata']['grants']['view_all_suppliers'])
				$_SESSION[$sub_menu]['org_id'] = $_SESSION['userdata']['org_id'];
			
			if ($_SESSION[$sub_menu]['org_id'])
				$where .= " and (org_id = {$_SESSION[$sub_menu]['org_id']})";
			*/

			$from_date = $_SESSION[$sub_menu]['from_date'];
			$to_date = $_SESSION[$sub_menu]['to_date'];
			if ($from_date)
				$where .= " and aviso_date >= '$from_date'";
			if ($to_date)
				$where .= " and aviso_date <= '$to_date'";

			if ($_SESSION[$sub_menu]['aviso_status'] != -1) {
				if ($_SESSION[$sub_menu]['aviso_status'] != '37')
					$where .= " and (aviso_status = '{$_SESSION[$sub_menu]['aviso_status']}')";
				else
					$where .= " and (aviso_status in ('3','7'))";
			}

			// Ако е извикано от подменютата за Инвестиционни или Оперативни разходи
			if ($_SESSION[$sub_menu]['where_add'])
				$where .= $_SESSION[$sub_menu]['where_add'];

			$data = _base::nomen_list('aviso', true, 'aviso_id', $where);
			echo json_encode(array('data' => $data));
		}


		function aviso_edt_complete () {
			// aviso_id
			$id = intVal($_REQUEST['p1']);

			if (!$id) return;

			if (!_base::CheckGrant('aviso_reception_view'))
				if (!_base::CheckAccess('aviso_reception_edit')) return;

			$data = _base::nomen_list_edit('aviso', $id, true);
			$warehouse_id = intVal($data['warehouse_id']);
			if ($_SESSION['userdata']['grants']['aviso_reception_delete'])
				$data['allow_delete'] = true;
			else
				$data['allow_delete'] = false;
			if ($_SESSION['userdata']['grants']['aviso_reception_edit'])
				$data['allow_edit'] = true;
			else
				$data['allow_edit'] = false;
			
			// Ако потребител към някой доставчик, без право да вижда всички доставчици, се опитва да отвори неправомерно друго Авизо
			if (intVal($_SESSION['userdata']['org_id']) and $data['org_id'] != $_SESSION['userdata']['org_id'] and !$_SESSION['userdata']['grants']['view_all_suppliers']) {
				$_SESSION['display_path'] = 'main_menu/deflt.tpl';
				$_SESSION['display_text'] = $this->smarty->getConfigVars('access_denied');
				return;
			}

			// Ако Авизото е старо и потребителя няма право view_all_suppliers "Достъп до всички Доставчици", да не може да го записва
			if (!$_SESSION['userdata']['grants']['view_all_suppliers']) {
				// Ако текущия час е > от config_aviso_until_time, то започваме от по-следващия работен ден
				$config_aviso_until_time = _base::get_config('config_aviso_until_time');
				if (!$config_aviso_until_time) $config_aviso_until_time = '17:00';
				if (strtotime($config_aviso_until_time) <= strtotime(date("H:i")))
					$days = 2;
				else
					$days = 1;
				// Зареждаме работните дни в масива working_days
				$this->load_working_days(date("Y-m-d"), 2);
				$curr_date = $this->next_working_day(date("Y-m-d"), $days);
				
				if ($curr_date > $data['aviso_date']) {
					$data['allow_delete'] = false;
					$data['allow_edit'] = false;
				}
			}

			// С какъв интерфейс се редактира
			//$warehouse_template = $data['warehouse_template'];
			//$_SESSION['display_path'] = "aviso/aviso_edit_".$warehouse_template.".tpl";

			$data['aviso_status_old'] = $data['aviso_status'];
			if ($data['aviso_status_old'] < '7')
				$data['aviso_status'] = '7';
			$this->smarty->assign ('data', $data);


			// Редовете от Авизото
			$data_line = array();
			$query_result = _base::get_query_result("select * from view_aviso_line WHERE aviso_id = $id order by aviso_line_id");
			while ($query_data = _base::sql_fetch_assoc($query_result)) {
				$data_line[] = $query_data + array('id' => $query_data['aviso_line_id']);
			}
			_base::sql_free_result($query_result);
			$this->smarty->assign ('data_line', json_encode($data_line));

			//_base::sql_add_field_width($query_result, $empty_line);

			_base::get_select_aviso_status(null, true);

			$this->smarty->assign ('callback_url', "$_SERVER[HTTP_REFERER]");

			$_SESSION['aviso_id'] = $id;
			$_SESSION['table_edit'] = 'aviso';
			_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['table_edit'], $id);
		}


		function aviso_save_complete () {
			// aviso_id
			$id = intVal($_REQUEST['p1']);

			if (!$id) return;
			if (!_base::CheckAccess('aviso_reception_edit', false)) return;
			
			// Проверки за неправомерност
			// Ако потребителя е с фиксиран org_id, проверка дали това Авизо е на същия org_id
			if (!$_SESSION['userdata']['grants']['view_all_suppliers'] and $_SESSION['userdata']['org_id']) {
				$temp = _base::select_sql("select org_id from aviso WHERE aviso_id = $id");
				if ($temp['org_id'] != $_SESSION['userdata']['org_id'])
					_base::show_error($this->smarty->getConfigVars('access_denied'));
			}

			$aviso_status_old = $_POST['aviso_status_old'];
			$aviso_status = $_POST['aviso_status'];

			_base::start_transaction();

			$query = new ExecQuery('aviso');
			$query->AddParam('aviso_status', 'c');
			$query->AddParam('aviso_reject_reason');

			//Попълва се в момента на сетване на статус от 0 на 3/7/9 или от 3 на 9
			//- изчиства се при сетване на статус от 3/7/9 на 0
			if ($aviso_status_old === '0' and $aviso_status >= '3')
				$query->AddParamExt('aviso_start_exec', date("Y-m-d H:i:s"), 'd');
			else
			if ($aviso_status_old >= '3' and $aviso_status === '0')
				$query->AddParamExt('aviso_start_exec', '', 'd');

			// Попълва се в момента на сетване на статус от 0/3 на 7/9
			// - изчиства се при сетване на статус от 7/9 на 3/0
			if ($aviso_status_old <= '3' and $aviso_status >= '7')
				$query->AddParamExt('aviso_end_exec', date("Y-m-d H:i:s"), 'd');
			else
			if ($aviso_status_old >= '7' and $aviso_status <= '3')
				$query->AddParamExt('aviso_end_exec', '', 'd');

			$query->update(["aviso_id" => $id]);
			
			$_SESSION['aviso_id'] = $id;


			// Запис в aviso_line
			// Ако е връщане на Авизо, направо нулирам приетите количества
			if ($aviso_status == '9') {
				$sql_query = "UPDATE aviso_line SET qty_pallet_rcvd = 0, qty_pack_rcvd = 0 WHERE aviso_id = $id";
				_base::execute_sql($sql_query);
			} else {
				$data_line = $_POST['data_line'];
				if ($data_line) {
					// data_line - array['aviso_line_id' => array[<field_name> => <value>]]
					$data_line = json_decode($data_line, true);
					foreach($data_line as $aviso_line_id => $line) {
						// AddParam ще добави параметъра, само ако е го има в масива
						$query = new ExecQuery('aviso_line');
						$query->a_get_values = $line;
						$query->add_cr_mo = false;
						$query->generator_name = false;

						$query->AddParam('qty_pallet_rcvd', 'n', 0);
						$query->AddParam('qty_pack_rcvd', 'n', 0);

						$query->update(["aviso_id" => $id, "aviso_line_id" => $aviso_line_id]);

						unset($query);
					}
				} // data_line
			}

			_base::commit_transaction();
			_base::put_sys_oper(__METHOD__, 'save', $_SESSION['table_edit'], $id);
			echo $id;
		}


		function aviso_display () {
			// aviso_id
			$aviso_id = $_REQUEST['p1'];
			// $_REQUEST['p2'] = thumb
			$thumb = ($_REQUEST['p2'] == 'thumb');
			$small_thumb = ($_REQUEST['p2'] == 'small_thumb');

			// Ако се иска thumb
			if ($thumb || $small_thumb) {
				_base::display_file('0.pdf', $thumb, $small_thumb);
				return ;
			}


			// Генериране на PDF

			// Данните от заглавния ред
			$query_result = _base::get_query_result("SELECT * FROM view_aviso WHERE aviso_id = $aviso_id");
			$aviso = _base::sql_fetch_assoc($query_result);
			_base::sql_free_result($query_result);
			$warehouse_type = $aviso['warehouse_type'];

			// Данните от редовете
			$query_result = _base::get_query_result("SELECT * FROM view_aviso_line WHERE aviso_id = $aviso_id order by shop_name, shop_id, metro_request_no");
			while ($query_data = _base::sql_fetch_assoc($query_result))
				$aviso_line[] = $query_data;
			_base::sql_free_result($query_result);

			// Данните за Доставчика
			$query_result = _base::get_query_result("SELECT * FROM view_org WHERE org_id = {$aviso['org_id']}");
			$org = _base::sql_fetch_assoc($query_result);
			_base::sql_free_result($query_result);

			// Данните за warehouse
			$query_result = _base::get_query_result("SELECT * FROM view_warehouse WHERE warehouse_id = {$aviso['warehouse_id']}");
			$warehouse = _base::sql_fetch_assoc($query_result);
			_base::sql_free_result($query_result);

			// Същинско генериране на файла
			$pdf = new aviso_PDF();
			$pdf->AddFont('Calibri','','calibri.php');
			$pdf->AddFont('Calibri','B','calibrib.php');
			$pdf->AddFont('Calibri','BI','calibribi.php');
			$pdf->AddFont('Calibri','I','calibrii.php');
			$pdf->AddPage();

			/*  
				Cell(float w [, float h [, string txt [, mixed border [, int ln [, string align [, boolean fill [, mixed link]]]]]]]) 
				Мярката е мм.
				
				mixed border
					0: no border
					1: frame
					cobined string
					L: left
					T: top
					R: right
					B: bottom

				int ln
					0: to the right
					1: to the beginning of the next line
					2: below
			*/
			
			// 210 - 10 - 10 = 190
			$pdf->SetLeftMargin(10);
			$pdf->SetRightMargin(10);
			
			$pdf->Image(INC_DIR.'/lagermax_logo.png',10,10,45);

			// 190-45 = 145
			$pdf->SetX(55);
			$pdf->SetFont('Calibri','BI',16);
			$pdf->Cell(145, 8, iconv('UTF-8', 'windows-1251', '„Лагермакс Спедицио България“ ЕООД'), 0, 1, 'R');

			//$pdf->SetXY(55, 18);
			$pdf->SetFont('Calibri','',10);
			$pdf->SetX(55);
			$pdf->Cell(145, 4, iconv('UTF-8', 'windows-1251', $warehouse['w_group_address']), 0, 1, 'R');
			$pdf->SetX(55);
			$pdf->Cell(145, 4, iconv('UTF-8', 'windows-1251', 'тел.: (+359) 2/996 22 13, ЕИК 131526370'), 0, 1, 'R');
			
			// Barcode 70, Дата 60, Час 60
			$pdf->SetFont('Calibri','',12);
			$pdf->SetX(10);
			$y = $pdf->GetY();
			$barcode_width = 80;
			$pdf->Cell($barcode_width, 20, '', 1, 0, 'L');
			/*
			$pdf->Cell(40, 10, iconv('UTF-8', 'windows-1251', 'Дата: ' . _base::MySqlDate2Str($aviso['aviso_date'])), 1, 0, 'C');
			$pdf->Cell(25, 10, iconv('UTF-8', 'windows-1251', 'Час: ' . substr($aviso['aviso_time'],0,5)), 1, 0, 'C');
			$pdf->Cell(190-65-$barcode_width, 10, iconv('UTF-8', 'windows-1251', $aviso['warehouse_code']), 1, 1, 'C');
			*/
			$pdf->SetFont('Calibri','B',16);
			$pdf->Cell(35, 8, iconv('UTF-8', 'windows-1251', _base::MySqlDate2Str($aviso['aviso_date'])), 1, 0, 'C');
			$pdf->Cell(25, 8, iconv('UTF-8', 'windows-1251', substr($aviso['aviso_time'],0,5)), 1, 0, 'C');
			$pdf->Cell(190-60-$barcode_width, 8, iconv('UTF-8', 'windows-1251', $aviso['warehouse_code']), 1, 1, 'C');

			// Доставчик:, платформа: warehouse_code
			$y1 = $pdf->GetY();
			$pdf->SetX(10+$barcode_width);
			$pdf->SetFont('Calibri','B',11);
			$pdf->Cell(190-$barcode_width, 6, iconv('UTF-8', 'windows-1251', $aviso['org_name']), 0, 0, 'L');
			$pdf->SetXY(10+$barcode_width, $y1+5);
			$pdf->SetFont('Calibri','',10);
			$pdf->Cell(190-$barcode_width, 7, iconv('UTF-8', 'windows-1251', $aviso['aviso_truck_no']), 0, 0, 'L');
			$pdf->SetXY(10+$barcode_width, $y1+5);
			$pdf->Cell(190-$barcode_width, 3, iconv('UTF-8', 'windows-1251', $aviso['aviso_driver_name']), 0, 0, 'R');
			$pdf->SetXY(10+$barcode_width, $y1+8);
			$pdf->Cell(190-$barcode_width, 4, iconv('UTF-8', 'windows-1251', $aviso['aviso_driver_phone']), 0, 0, 'R');
			//$pdf->MultiCell(190-$barcode_width, 4, iconv('UTF-8', 'windows-1251', $aviso['aviso_driver_name'] . "\n" . $aviso['aviso_driver_phone']), 0, 'R');
			$pdf->SetXY(10+$barcode_width, $y1);
			$pdf->Cell(190-$barcode_width, 12, '', 1, 0, 'L');


			// Сега се събират до 13 цифри при 0.5 мащабиране
			$pdf->SetFont('Calibri','B',14);
			$pdf->Code128(20,$y+2,$aviso['aviso_id'],$barcode_width-10, 12);
			$pdf->SetXY(20,$y+15);
			$pdf->Write(5, $aviso['aviso_id']);


			// таблица с редовете от aviso_line
			$pdf->SetFont('Calibri','B',11);
			$pdf->Ln();
			// Метро магазин, Доставчик Номер, Поръчка, ПАЛЕТИ Бр., Кг, куб. м.,  КОЛЕТИ Бр., Кг, куб. м.
			// Метро магазин - само за '3' PAXD
			if ($warehouse_type == '3') {
				$w = array(50, 20, 30, 10,20,15, 10,20,15);
			} else {
				$w = array(50, 20, 30, 10,20,15, 10,20,15);
			}
			$i = 0;
			// Заглавен ред на таблицата
			$y = $pdf->GetY();
			if ($warehouse_type == '3')
				$pdf->Cell($w[0],10, iconv('UTF-8', 'windows-1251', "Метро магазин"), 1, 0, 'C');
			else
				$pdf->Cell($w[0],10, iconv('UTF-8', 'windows-1251', ""), 1, 0, 'C');
			$pdf->Cell($w[1],5, iconv('UTF-8', 'windows-1251', "Доставчик"), 'TR', 2, 'C');
			$pdf->Cell($w[1],5, iconv('UTF-8', 'windows-1251', "Номер"), 'BR', 0, 'C');
			$pdf->SetXY($pdf->GetX(), $y);
			$pdf->Cell($w[2],10, iconv('UTF-8', 'windows-1251', "Поръчка"), 1, 0, 'C');
			$pdf->Cell($w[3]+$w[4]+$w[5],5, iconv('UTF-8', 'windows-1251', "ПАЛЕТИ"), 1, 2, 'C');
			$pdf->Cell($w[3],5, iconv('UTF-8', 'windows-1251', "Бр."), 1, 0, 'C');
			$pdf->Cell($w[4],5, iconv('UTF-8', 'windows-1251', "Кг"), 1, 0, 'C');
			$pdf->Cell($w[5],5, iconv('UTF-8', 'windows-1251', "куб. м."), 1, 0, 'C');
			$pdf->SetXY($pdf->GetX(), $y);
			$pdf->Cell($w[6]+$w[7]+$w[8],5, iconv('UTF-8', 'windows-1251', "КОЛЕТИ"), 1, 2, 'C');
			$pdf->Cell($w[6],5, iconv('UTF-8', 'windows-1251', "Бр."), 1, 0, 'C');
			$pdf->Cell($w[7],5, iconv('UTF-8', 'windows-1251', "Кг"), 1, 0, 'C');
			$pdf->Cell($w[8],5, iconv('UTF-8', 'windows-1251', "куб. м."), 1, 0, 'C');

			// Детайлни редове
			$pdf->SetFont('Calibri','',11);
			$pdf->Ln();
			$h = 8;
			$i = 0;
			// $aviso_line
			$x0 = $x = $pdf->GetX();
			$y = $pdf->GetY();
			// В $yH ще остане най-голямата височина на редовете
			$yH = $h;
			$pdf->SetXY($x0, $y);
			$last_shop_id = '';
			$pallet_weight = 0;
			$pallet_volume = 0;
			$pack_weight = 0;
			$pack_volume = 0;
			if ($aviso_line) {
				foreach($aviso_line as $line) {

					if ($last_shop_id != $line['shop_id'])
						$pdf->MultiCell($w[0],$h, iconv('UTF-8', 'windows-1251', $line['shop_name']), 'LRT', 'L');
					else
						$pdf->MultiCell($w[0],$h, '', 'LR', 'L');
					$last_shop_id = $line['shop_id'];
					$x = $x + $w[0];
					$yH = max($yH, $pdf->GetY() - $y);

					$pdf->SetXY($x, $y);
					$pdf->MultiCell($w[1],$h, iconv('UTF-8', 'windows-1251', $line['org_metro_code']), 'LR', 'L');
					$x = $x + $w[1];
					$yH = max($yH, $pdf->GetY() - $y);

					$pdf->SetXY($x, $y);
					$pdf->MultiCell($w[2],$h, iconv('UTF-8', 'windows-1251', $line['metro_request_no']), 'LR', 'L');
					$x = $x + $w[2];
					$yH = max($yH, $pdf->GetY() - $y);

					// ПАЛЕТИ Бр., Кг, куб. м.
					$pdf->SetXY($x, $y);
					$pdf->MultiCell($w[3],$h, $line['qty_pallet'] ? $line['qty_pallet'] : '', 'LR', 'R');
					$x = $x + $w[3];
					$yH = max($yH, $pdf->GetY() - $y);

					$pdf->SetXY($x, $y);
					//$pdf->MultiCell($w[4],$h, $line['qty_pallet'] ? number_format($line['weight'], 3, '.', '') : '', 'LR', 'R');
					$pdf->MultiCell($w[4],$h, $line['qty_pallet'] ? floatVal($line['weight']) : '', 'LR', 'R');
					$x = $x + $w[4];
					$yH = max($yH, $pdf->GetY() - $y);

					$pdf->SetXY($x, $y);
					//$pdf->MultiCell($w[5],$h, $line['qty_pallet'] ? number_format($line['volume'], 3, '.', '') : '', 'LR', 'R');
					$pdf->MultiCell($w[5],$h, $line['qty_pallet'] ? floatVal($line['volume']) : '', 'LR', 'R');
					$x = $x + $w[5];
					$yH = max($yH, $pdf->GetY() - $y);


					// КОЛЕТИ Бр., Кг, куб. м.
					$pdf->SetXY($x, $y);
					$pdf->MultiCell($w[6],$h, $line['qty_pack'] ? $line['qty_pack'] : '', 'LR', 'R');
					$x = $x + $w[6];
					$yH = max($yH, $pdf->GetY() - $y);

					$pdf->SetXY($x, $y);
					$pdf->MultiCell($w[7],$h, $line['qty_pack'] ? floatVal($line['weight']) : '', 'LR', 'R');
					$x = $x + $w[7];
					$yH = max($yH, $pdf->GetY() - $y);

					$pdf->SetXY($x, $y);
					$pdf->MultiCell($w[8],$h, $line['qty_pack'] ? floatVal($line['volume']) : '', 'LR', 'R');
					$x = $x + $w[8];
					$yH = max($yH, $pdf->GetY() - $y);

					if ($line['qty_pallet']) {
						$pallet_weight += $line['weight'];
						$pallet_volume += $line['volume'];
					} else {
						$pack_weight += $line['weight'];
						$pack_volume += $line['volume'];
					}

					// Изчертаване на линиите, започвайки от втората колона
					$x = $x0;
					for($j = 0; $j < count($w) ; $j++) {
						$pdf->SetXY($x, $y);
						if ($j == 0)
							$pdf->Cell($w[$j], $yH, "", 'LR',0,'');
						else
							$pdf->Cell($w[$j], $yH, "", 'LRB',0,'');
						$x = $x + $w[$j];
					}

					$y = $y + $yH; //move to next row
					$yH = $h;
					$x = $x0; //start from first column
					$pdf->SetXY($x0, $y);
				}
				// Черта най-отдолу, ама само ако не чертая за всеки ред
				$pdf->Cell(190,0, '', 'T');
			}

			$pdf->Ln();

			// ТОТАЛ
			$pdf->SetFont('Calibri','B',11);
			//  Cell(float w [, float h [, string txt [, mixed border [, int ln [, string align [, boolean fill [, mixed link]]]]]]]) 
			$pdf->Cell($w[0],$h, iconv('UTF-8', 'windows-1251', "ТОТАЛ"), 1, 0, 'R');
			$pdf->Cell($w[1],$h, '', 1, 0);
			$pdf->Cell($w[2],$h, '', 1, 0);
			$pdf->Cell($w[3],$h, $aviso['qty_pallet'], 1, 0, 'R');
			$pdf->Cell($w[4],$h, $pallet_weight, 1, 0, 'R');
			$pdf->Cell($w[5],$h, $pallet_volume, 1, 0, 'R');
			$pdf->Cell($w[6],$h, $aviso['qty_pack'], 1, 0, 'R');
			$pdf->Cell($w[7],$h, $pack_weight, 1, 0, 'R');
			$pdf->Cell($w[8],$h, $pack_volume, 1, 0, 'R');

			$pdf->Ln(10);
			// Общи приказки
			$pdf->SetFont('Calibri','I',11);
			$s = '* За да гарантираме бързото разтоварване на Вашите камиони в склада, се нуждаем от подкрепата Ви.';
			$pdf->MultiCell(190,5, iconv('UTF-8', 'windows-1251', $s), 0, 'L');
			$s = '* Моля, регистрирайте се с Авизото си на Прием Документи, минимум 5 минути преди запазения от Вас час за доставка.';
			$pdf->MultiCell(190,5, iconv('UTF-8', 'windows-1251', $s), 0, 'L');
			$s = '* След като Ви бъде определена рампа, предайте всички придружаващи документи и заемете мястото си на рампата';
			$pdf->MultiCell(190,5, iconv('UTF-8', 'windows-1251', $s), 0, 'L');
			$s = '* Един запазен времеви прозорец дава право на доставка с едно транспортно средство.';
			$pdf->MultiCell(190,5, iconv('UTF-8', 'windows-1251', $s), 0, 'L');
			$s = '* Неавизирани доставки няма да бъдат приемани.';
			$pdf->MultiCell(190,5, iconv('UTF-8', 'windows-1251', $s), 0, 'L');


			// I - направо се отваря в прозореца
			// D - download
			$pdf->Output('I', $aviso['scan_doc']);
			_base::put_sys_oper(__METHOD__, 'pdf', 'aviso', $aviso_id);
		}

	}
?>
