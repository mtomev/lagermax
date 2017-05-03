<?php
	class sys_reports {

		function __construct ($smarty) {
			$this->smarty = $smarty;
		}
		
		function __destruct () {}
		
		function deflt () {
		 	if (!_base::CheckAccess('sys_reports')) return;
			// Ако е подаден $_REQUEST['p1'], то тогава се извиква от бутона Изпълни
			if (!$_REQUEST['p1']) {
				$_SESSION['main_menu'] = 'sys_reports';
				$_SESSION['sub_menu'] = '-';
			}
			//$_SESSION{'display_path'} = 'sys_reports/deflt.tpl';
		}

		function sys_oper () {
			if (!_base::CheckAccess('sys_oper')) return;

			// $_POST съдържа следните параметри: from_date, to_date, user_id
			// Ако е подаден $_REQUEST['p1'], то тогава се извиква от бутона Изпълни
			
			$_SESSION['main_menu'] = 'sys_reports';
			$_SESSION['sub_menu'] = 'sys_oper';
			_base::readFilterToSESSION_new('sys_oper');
			$this->smarty->assign ('current_url', '/sys_reports/sys_oper');

			if (!isset($_SESSION['sys_oper']['user_id']))
				$_SESSION['sys_oper']['user_id'] = 0;

			_base::get_select_list_sql('select user_id, coalesce(user_full_name, user_name) user_name from view_user order by 2', 'select_user');
			
			// Ако няма посочени дати
			if (isset($_SESSION['sys_oper']['from_date']))
				$from_date = _base::Str2MySqlDate($_SESSION['sys_oper']['from_date']);
			else {
				// Днешна дата - 7 дни
				$from_date = date('Y-m-d', strtotime(gmdate("Y-m-d"). ' - 7 days'));
				$_SESSION['sys_oper']['from_date'] = $from_date;
			}
			if (isset($_SESSION['sys_oper']['to_date']))
				$to_date = _base::Str2MySqlDate($_SESSION['sys_oper']['to_date']);
			else
				$to_date = '';

			$user_id = intVal($_SESSION['sys_oper']['user_id']);

			// По подразбиране - сумарно
			if (!isset($_SESSION['sys_oper']['summarize']))
				$_SESSION['sys_oper']['summarize'] = '1';

			if (isset($_REQUEST['p1'])) {
				if ($to_date)
					$to_date = date('Y-m-d', strtotime($to_date. ' + 1 day'));
				if ($_SESSION['sys_oper']['summarize']) {
					$sql_query = "select sys_oper.user_id, coalesce(view_user.user_full_name, view_user.user_name) user_name,
						count(*) as cnt_oper
						from sys_oper
						left outer join view_user on view_user.user_id = sys_oper.user_id
						where (1=1)";
					if ($user_id)
						$sql_query .= " and sys_oper.user_id = $user_id";
					if ($from_date)
						$sql_query .= " and sys_oper.oper_date >= '$from_date'";
					if ($to_date)
						$sql_query .= " and sys_oper.oper_date < '$to_date'";
					$sql_query .= " group by 1,2 order by 2";
					$query_result = _base::get_query_result($sql_query);
					while ($query_data = _base::sql_fetch_assoc($query_result)) {
						$data[] = $query_data + array('id' => $query_data['user_id']);
					}
					_base::sql_free_result($query_result);
					$columns = array();
				} else {
					$sql_query = "select sys_oper.*, coalesce(view_user.user_full_name, view_user.user_name) user_name
						from sys_oper
						left outer join view_user on view_user.user_id = sys_oper.user_id
						where (1=1)";
					if ($user_id)
						$sql_query .= " and sys_oper.user_id = $user_id";
					if ($from_date)
						$sql_query .= " and sys_oper.oper_date >= '$from_date'";
					if ($to_date)
						$sql_query .= " and sys_oper.oper_date < '$to_date'";
					$sql_query .= " order by sys_oper_id desc";
					$query_result = _base::get_query_result($sql_query);
					while ($query_data = _base::sql_fetch_assoc($query_result)) {
						$data[] = $query_data + array('id' => $query_data['sys_oper_id']);
					}
					$fields = _base::get_fields_name($query_result);
					_base::sql_free_result($query_result);
					foreach($fields as $finfo)
						$columns[] = array('title' => $finfo, 'name' => $finfo, 'data' => $finfo);
				}
			} else {
				$data = array();
				$columns = array();
			}

			$this->smarty->assign ('data', json_encode($data));
			$this->smarty->assign ('columns', json_encode($columns));

			_base::set_table_edit_AccessRights('sys_oper');
			_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
		}

		function sys_logon () {
			if (!_base::CheckAccess('sys_logon')) return;

			// $_POST съдържа следните параметри: from_date, to_date, user_id
			// Ако е подаден $_REQUEST['p1'], то тогава се извиква от бутона Изпълни
			
			// Ако е инициализиране на справката
			if (!$_REQUEST['p1']) {
				$_SESSION['main_menu'] = 'sys_reports';
				$_SESSION['sub_menu'] = 'sys_logon';
				_base::readFilterToSESSION_new('sys_logon');
				$this->smarty->assign ('current_url', '/sys_reports/sys_logon');

				_base::get_select_list_sql('select user_id, coalesce(user_full_name, user_name) user_name from view_user order by 2', 'select_user');

				if (!isset($_SESSION['sys_logon']['user_id']))
					$_SESSION['sys_logon']['user_id'] = 0;

				if (!isset($_SESSION['sys_logon']['from_date']))
					// Днешна дата - 7 дни
					$_SESSION['sys_logon']['from_date'] = date('Y-m-d', strtotime(gmdate("Y-m-d"). ' - 7 days'));
					
				$columns = array();
				$sql_query = "select sys_logon.*, coalesce(view_user.user_full_name, view_user.user_name) user_name
					from sys_logon
					left outer join view_user on view_user.user_id = sys_logon.logon_user_id";
				$query_result = _base::get_query_result($sql_query);
				$fields = _base::get_fields_name($query_result);
/*
while ($finfo = mysqli_fetch_field ($query_result))
	print nl2br2 (print_r($finfo->length, true) . PHP_EOL);
*/
				_base::sql_free_result($query_result);
				foreach($fields as $finfo)
					$columns[] = array('title' => $finfo, 'name' => $finfo, 'data' => $finfo);
				$this->smarty->assign ('columns', json_encode($columns));

				_base::set_table_edit_AccessRights('sys_logon');
				_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);

				return;
			}

			_base::readFilterToSESSION_new('sys_logon');
			$_SESSION['display_path'] = '_dummy_';

			// Ако няма посочени дати
			if (isset($_SESSION['sys_logon']['from_date']))
				$from_date = _base::Str2MySqlDate($_SESSION['sys_logon']['from_date']);
			else {
				// Днешна дата - 7 дни
				$from_date = date('Y-m-d', strtotime(gmdate("Y-m-d"). ' - 7 days'));
				$_SESSION['sys_logon']['from_date'] = $from_date;
			}
			if (isset($_SESSION['sys_logon']['to_date']))
				$to_date = _base::Str2MySqlDate($_SESSION['sys_logon']['to_date']);
			else
				$to_date = '';

			$user_id = intVal($_SESSION['sys_logon']['user_id']);


			if ($to_date)
				$to_date = date('Y-m-d', strtotime($to_date. ' + 1 day'));
			$sql_query = "select sys_logon.*, coalesce(view_user.user_full_name, view_user.user_name) user_name
				from sys_logon
				left outer join view_user on view_user.user_id = sys_logon.logon_user_id
				where (1=1)";
			if ($user_id)
				$sql_query .= " and sys_logon.logon_user_id = $user_id";
			if ($from_date)
				$sql_query .= " and sys_logon.logon_date >= '$from_date'";
			if ($to_date)
				$sql_query .= " and sys_logon.logon_date < '$to_date'";
			$sql_query .= " order by logon_id desc";
			$query_result = _base::get_query_result($sql_query);
			while ($query_data = _base::sql_fetch_assoc($query_result)) {
				$detail[] = $query_data + array('id' => $query_data['logon_id']);
			}
			_base::sql_free_result($query_result);

			echo json_encode($detail);
		}

	}
?>
