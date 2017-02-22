<?php
	class main_menu {
	    
		function __construct (&$smarty) {
			$this->smarty = $smarty;
		}
		
		function __destruct () {}
		
		function deflt () {
			$_SESSION['main_menu'] = 'home';
		}
		
		function selectlanguage () {
			$clang = $_REQUEST['p1'];
			if (in_array ($clang, $_SESSION['langs'])) $_SESSION['lang']['lang'] = $clang;
		}
		

		function languages () {
		 	if (!_base::CheckAccess('languages')) return;
			$_SESSION['main_menu'] = 'configuration';
			$_SESSION['sub_menu'] = 'languages';
			
			$clang = $_REQUEST['p1'];
			if (in_array ($clang, $_SESSION['langs'])) {
				$fname = $this->smarty->config_dir[0] . "lang_" . $clang . ".txt";
				$lang_data = file_get_contents ($fname);
				$this->smarty->assign ('lang_data', $lang_data);
				$this->smarty->assign ('clang', $clang);
			}
			if (!$clang)
				_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
			else
				_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['sub_menu'], 0, $clang);
		}

		function languages_save () {
		 	if (!_base::CheckAccess('languages')) return;
			$clang = $_REQUEST['p1'];
			if (in_array ($clang, $_SESSION['langs'])) {
				$fname = $this->smarty->config_dir[0] . "lang_" . $clang . ".txt";

				// Първо бекъп на стария файл с текуща дата и час на промяна в UTC в папка /backup
				$backup_path = $this->smarty->config_dir[0]."/backup";
				if (!is_dir($backup_path))
					mkdir($backup_path, 0777, true);
				$timestamp = gmdate("Ymd_His");
				$backup_fname = $backup_path."/lang_$clang"."_$timestamp.txt";
				rename($fname, $backup_fname);

				$lang_data = file_put_contents ($fname, $_POST['lang_data']);
				_base::put_sys_oper(__METHOD__, 'save', 'languages', 0, $clang);
			}
		}


		function config_edit () {
		 	if (!_base::CheckAccess('config_edit')) return;
			$_SESSION['main_menu'] = 'configuration';
			$_SESSION['sub_menu'] = 'config';
			
			// Да изчетем в data всички настройки. Индекса на data ще е config_name
			$sql_query = "SELECT * FROM config";
			$query_result = _base::get_query_result($sql_query);
			while ($query_data = _base::sql_fetch_assoc($query_result, true)) {
				$data[$query_data['config_name']] = $query_data['config_value'];
			}
			_base::sql_free_result($query_result);

			$this->smarty->assign('data', $data);

			_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['sub_menu'], 0);
		}

		function config_save () {
		 	if (!_base::CheckAccess('config_edit')) return;
			
			// За всяка променлива от $_POST, трябва да се направи update or insert
			$table = 'config';
			_base::start_transaction();

			// Да изчетем в data всички настройки. Индекса на data ще е config_name
			$sql_query = "SELECT * FROM config";
			$query_result = _base::get_query_result($sql_query);
			$data = array();
			while ($query_data = _base::sql_fetch_assoc($query_result, true)) {
				$data[$query_data['config_name']] = array('config_value' => $query_data['config_value'], 'config_id' => $query_data['config_id']);
			}
			_base::sql_free_result($query_result);

			foreach($_POST as $config_name => $config_value) {
				// Ако няма промяна на стойността
				if ($_POST[$config_name] == $data[$config_name]['config_value']) continue;
				
				// Ако има checkbox's, трябва да се подава и $type = 'c'

				$query = new ExecQuery($table);
				$query->AddParamExt('config_name', $config_name);
				$query->AddParamExt('config_value', $config_value);
				// Ако липсва от $data, значи трябва да се прави insert
				if (array_key_exists($config_name, $data))
					$query->update([$table."_id" => $data[$config_name]['config_id']]);
				else
					$query->insert();
				unset($query);
			}

			_base::commit_transaction();
			_base::put_sys_oper(__METHOD__, 'save', 'config', 0);
		}


		function login () {
			// Ако идва от shortcut, а потребителя не се е логнал
			if ($_SESSION['relogin_url'])
				$_SESSION['display_path'] = $_SESSION['relogin_url'];
			else {
				// Ако има първи параметър - номера на Доставчик org_id
				$org_id = intVal($_REQUEST['p1']);
			}

			$logon_user_id = 0;

			if (!$_POST['login_user'] or !$_POST['login_pass']) {
				echo '0';
				return;
			}

			// try to login the user
			$user = _base::escape_string($_POST['login_user']);
			$pass = _base::escape_string($_POST['login_pass']);
			$org_id = intVal($_POST['org_id']);
			
			$sql_query = "SELECT * FROM view_user WHERE user_name = '$user' AND user_password = '$pass' AND org_id = $org_id and (is_active = '1')";
			$query_result = _base::get_query_result($sql_query);

			$query_data = _base::sql_fetch_assoc($query_result);
			_base::sql_free_result($query_result);
			if ($query_data) {
				$_SESSION['loggedin'] = true;
				$_SESSION['userdata'] = $query_data;

				$sql_query = "SELECT grants
					FROM user_role 
					WHERE user_role_id = ". $_SESSION['userdata']['user_role_id'];
				$query_result = _base::get_query_result($sql_query);
				$grants = _base::sql_fetch_assoc($query_result);
				_base::sql_free_result($query_result);
				$_SESSION['userdata']['grants'] = json_decode($grants['grants'], true);;

				$reason = 'Login successful!';
				
				$logon_user_id = $_SESSION['userdata']['user_id'];
				
				unset($_SESSION['relogin_url']);
			}
			

			if ($logon_user_id)
				$logon_note = '';
			else
				$logon_note = _base::escape_string("wrong ".$org_id."/".$user."/".$pass);

			/*
			if (version_compare(PHP_VERSION, '5.3.0') >= 0)
				$logon_comp_name = _base::escape_string(gethostname());
			*/
			$logon_comp_name = gethostbyaddr($_SERVER['REMOTE_ADDR']);

			// Запис в sys_logon
			$curr_time = gmdate("Y-m-d H:i:s");
			_base::start_transaction();

			$query = new ExecQuery('sys_logon');
			$query->generator_name = 'logon_id';
			$query->pk_name = 'logon_id';
			$query->add_cr_mo = false;
			$query->AddParamExt('logon_note', $logon_note, 's', null);
			$query->AddParamExt('logon_ip_addr', $_SERVER['REMOTE_ADDR'], 's', null);
			$query->AddParamExt('logon_comp_name', $logon_comp_name, 's', null);
			$query->AddParamExt('logon_user_id', $logon_user_id, 'n', 0);
			$query->AddParamExt('logon_date', $curr_time, 'd', null);
			$new_id = $query->insert();
			unset($query);

			_base::commit_transaction();
			$_SESSION['userdata']['logon_id'] = $new_id;

			// При успешен Login, връщаме 1
			if ($logon_user_id)
				echo '1';
			else
				echo '0';
		}
		
		function logout () {
			session_unset();
		}


		function mail_password () {
			$logon_user_id = 0;

			if (!$_POST['login_user']) {
				echo 'Попълнете "Доставчик номер" и "Име"';
				return;
			}

			// try to login the user
			$user = _base::escape_string($_POST['login_user']);
			$org_id = intVal($_POST['org_id']);
			
			$sql_query = "SELECT * FROM view_user WHERE user_name = '$user' AND org_id = $org_id and (is_active = '1')";
			$query_result = _base::get_query_result($sql_query);

			$query_data = _base::sql_fetch_assoc($query_result);
			_base::sql_free_result($query_result);
			if (!$query_data or $query_data['is_active'] != '1') {
				echo 'Несъществуващи "Доставчик номер" или "Име"';
				return;
			}
			if (!$query_data['user_email']) {
				echo 'Няма посочен e-mail за потребителя';
				return;
			}

			if (!_base::send_user_mail($query_data, false)) return;

			$logon_user_id = $query_data['user_id'];
			$logon_comp_name = gethostbyaddr($_SERVER['REMOTE_ADDR']);

			// Запис в sys_logon
			$curr_time = gmdate("Y-m-d H:i:s");
			_base::start_transaction();

			$query = new ExecQuery('sys_logon');
			$query->generator_name = 'logon_id';
			$query->pk_name = 'logon_id';
			$query->add_cr_mo = false;
			$query->AddParamExt('logon_note', 'mail_password', 's', null);
			$query->AddParamExt('logon_ip_addr', $_SERVER['REMOTE_ADDR'], 's', null);
			$query->AddParamExt('logon_comp_name', $logon_comp_name, 's', null);
			$query->AddParamExt('logon_user_id', $logon_user_id, 'n', 0);
			$query->AddParamExt('logon_date', $curr_time, 'd', null);
			$new_id = $query->insert();
			unset($query);

			_base::commit_transaction();
			$_SESSION['userdata']['logon_id'] = $new_id;

			// При успешен mail, връщаме 1
			echo '1';
		}
		
	}

?>
