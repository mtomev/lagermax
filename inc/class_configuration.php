<?php
	class configuration {

		function __construct ($smarty) {
			$this->smarty = $smarty;
		}

		function __destruct () {}

		private function nomen_list_json($table, $sql_query, $field_id = null) {
			// Прави стандартно попълване на $data за <table>_list
			$data = _base::nomen_list($sql_query, $field_id);

			$this->smarty->assign('data', json_encode($data, JSON_UNESCAPED_UNICODE));
			_base::set_table_edit_AccessRights($table);
			return $data;
		}

		function list_refresh () {
			$table = $_REQUEST['p1'];
			$grant = $table.'_edit';
			if ($table == 'user_role')
				$grant = 'user_edit';
			if ($table == 'aviso')
				$grant = 'aviso';
		 	if (!_base::CheckGrant($grant)) {
				echo json_encode(array(), JSON_UNESCAPED_UNICODE);
				return;
			}

			// table_name/r_temp_id=<id>
			if (_base::parseREQUEST_p('p2', $param_name, $param_value)) {
				$field_id = $param_name;
				$id = $param_value;
			} else {
				$id = $_REQUEST['p2'];
				unset($field_id);
			}

			// Ако $id === 0, то трябва да се върне последно добавения елемент $_SESSION['<table>_id']
			if (!$id)
				$id = $_SESSION[$table.'_id'];
			if (!$id) return;

			$is_view = _base::is_view_exists($table);
			$id = intVal($id);
			if (!$field_id) $field_id = $table.'_id';
			if (!$is_view)
				$sql_query = "SELECT * FROM {$table} WHERE $field_id = $id";
			else
				$sql_query = "SELECT * FROM view_{$table} WHERE $field_id = $id";

			$data = _base::nomen_list_refresh($sql_query, $id);
			if ($table == 'aviso') {
				// Проверки за неправомерност
				// Ако потребителя е с фиксиран org_id, проверка дали това Авизо е на същия org_id
				if (!$_SESSION['userdata']['grants']['view_all_suppliers'] and $_SESSION['userdata']['org_id']) {
					echo json_encode(array(), JSON_UNESCAPED_UNICODE);
					return;
				}
			}
			echo json_encode($data, JSON_UNESCAPED_UNICODE);
		}

		private function ajax_list ($sql_query, $field_id = null) {
			$query_result = _base::get_query_result($sql_query);
			$fields = _base::get_fields_name($query_result);
			$fields[] = 'id';
			// Ако не е подадено името на полето за id, взимам първото поле
			if ($field_id)
				$indexOfID = array_search($field_id, $fields);
			else
				$indexOfID = 0;
			while ($query_data = _base::sql_fetch_row($query_result)) {
				$query_data[] = $query_data[$indexOfID];
				$data[] = $query_data;
			}
			_base::sql_free_result($query_result);
			$this->smarty->assign('data', json_encode($data), JSON_UNESCAPED_UNICODE);
			_base::set_table_edit_AccessRights($table);
			echo json_encode(array('data' => $data, 'fields' => $fields), JSON_UNESCAPED_UNICODE);
		}


		/*function mass_mailing () {
			// Изпращане на мейли в групи от по 100
			$sql_query = "SELECT user_id, user_email, user_full_name, org_id, org_name, user_name, user_password from view_user";
      $sql_query .= PHP_EOL . "where is_active = '1' and user_email is not null and user_email <> '' and email_sended <> '1'";
      $sql_query .= PHP_EOL . "order by user_id";
      $sql_query .= PHP_EOL . "limit 100";
			$query_result = _base::get_query_result($sql_query);
			while ($query_data = _base::sql_fetch_assoc($query_result))
				$temp[] = $query_data;
			_base::sql_free_result($query_result);

			if ($temp) {
				$mail = new MyMailer;
				// SMTP connection will not close after each email sent, reduces SMTP overhead
				$mail->SMTPKeepAlive = true;
				$mail->Subject = "WEB портал на Метро платформа Лагермакс";
				_base::start_transaction();
				foreach($temp as $data_mail) {
					if ($data_mail['user_email']) {
						$mail->AddAddress($data_mail['user_email']);
						$mail->Body = 
							"Това е автоматично съобщение, което Ви предоставя достъп до WEB портала за Заявки на Метро платформа Лагермакс"
							. PHP_EOL
							. PHP_EOL . "http://$_SERVER[HTTP_HOST]". ($data_mail['org_id'] ? "/".$data_mail['org_id'] : "")
							. PHP_EOL
							. PHP_EOL . "Доставчик име: ".$data_mail['org_name']
							. PHP_EOL . "Доставчик номер: ".$data_mail['org_id']
							. PHP_EOL . "Име: ".$data_mail['user_name']
							. PHP_EOL . "Парола: ".$data_mail['user_password'];

						if(!$mail->Send()) {
							echo $data_mail['user_id'] . PHP_EOL . 'Mailer Error: ' . $mail->ErrorInfo;
							//break;
						}
						$mail->clearAddresses();
					}
					$sql_query = "UPDATE `user` set email_sended = '1' where user_id = ".$data_mail['user_id'];
					_base::execute_sql($sql_query);
				}
				_base::commit_transaction();
			}
		}*/


		/*function temp_update () {
			$sql_query = "SELECT aviso.*, pltorg.pltorg_id from aviso";
      $sql_query .= PHP_EOL . "left outer join pltorg on pltorg.aviso_id = aviso.aviso_id";
      $sql_query .= PHP_EOL . "where aviso.aviso_status = '7'";
      $sql_query .= PHP_EOL . "order by aviso.aviso_id";
			$query_result = _base::get_query_result($sql_query);
			while ($query_data = _base::sql_fetch_assoc($query_result))
				$temp[] = $query_data;
			_base::sql_free_result($query_result);

			$a_fields = array('plt_eur','plt_chep','plt_other', 'ret_plt_eur','ret_plt_eur','ret_plt_eur', 'claim_plt_eur','claim_plt_eur','claim_plt_eur');

			if ($temp) {
				_base::start_transaction();
				foreach($temp as $aviso) {
					$has_difference = false;
					for($i=0, $count=count($a_fields); $i < $count; $i++) {
						if ( intVal($aviso['aviso_'.$a_fields[$i]]) ) {
							$has_difference = true;
							break;
						}
					}
					if ($has_difference) {
						$query = new ExecQuery('pltorg', false);
						$query->add_cr_mo = false;
						
						for($i=0, $count=count($a_fields); $i < $count; $i++) {
							if ( intVal($aviso['aviso_'.$a_fields[$i]]) ) {
								$query->AddParamExt('qty_'.$a_fields[$i], $aviso['aviso_'.$a_fields[$i]], 'n', 0);
							}
						}

						if ($aviso['pltorg_id'])
							$query->update(["aviso_id" => $aviso['aviso_id']]);
						else 
						// Ако не е имало запис в pltorg
						{
							$query->AddParamExt('aviso_id', $aviso['aviso_id'], 'n', 0);
							$query->AddParamExt('org_id', $aviso['org_id'], 'n', 0);
							$query->AddParamExt('pltorg_date', $aviso['aviso_date'], 'd');
							$query->AddParamExt('pltorg_driver', $aviso['aviso_driver_name']);

							$query->AddParamExt('cr_user_id', $aviso['cr_user_id'], 'n', 0);
							$query->AddParamExt('mo_user_id', $aviso['mo_user_id'], 'n', 0);
							$query->AddParamExt('cr_date', $aviso['cr_date'], 'd');
							$query->AddParamExt('mo_date', $aviso['mo_date'], 'd');

							$query->insert();
						}
						unset($query);
					}
				}
				_base::commit_transaction();
			}
		}*/


		function warehouse () {
		 	if (!_base::CheckAccess('warehouse')) return;
			$_SESSION['main_menu'] = 'configuration';
			$_SESSION['sub_menu'] = 'warehouse';
			$this->nomen_list_json($_SESSION['sub_menu'], "select * from view_warehouse order by warehouse_name");
			_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
		}

		function warehouse_edit () {
		 	if (!_base::CheckGrant('warehouse_view'))
				if (!_base::CheckAccess('warehouse_edit')) return;

			$id = intVal($_REQUEST['p1']);

			_base::get_select_list('w_group');
			_base::get_select_warehouse_type();

			$data = _base::nomen_list_edit('warehouse', $id, true);
			
			// При нов, някои подразбиращи се стойности
			if (!$id) {
				$data['warehouse_template'] = '1';
				$data['warehouse_type'] = '0';
			}

			$this->smarty->assign ('data', $data);
			$_SESSION['warehouse_id'] = $id;
			$_SESSION['table_edit'] = 'warehouse';
			
			_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['table_edit'], $id);
		}

		function warehouse_save () {
		 	if (!_base::CheckAccess('warehouse_edit')) return;

			$id = intVal($_REQUEST['p1']);
			$table = 'warehouse';

			_base::start_transaction();
			$query = new ExecQuery($table);
			$query->AddParam($table.'_name');
			$query->AddParam('w_group_id', 'n', 0);
			$query->AddParam('warehouse_code');
			$query->AddParam('w_start_time', 't');
			$query->AddParam('w_end_time', 't');
			$query->AddParam('w_interval', 'n', 0);
			$query->AddParam('w_count', 'n', 0);
			$query->AddParam('w_max_pallet', 'n', 0);
			$query->AddParam('w_pack2pallet', 'n', 0);
			$query->AddParam('warehouse_template');
			$query->AddParam('warehouse_type');
			$query->AddParam('is_active', 'c');
			if ($id != 0) {
				$query->update([$table."_id" => $id]);
				$new_id = $id;
			}
			else
				$new_id = $query->insert();
			unset($query);
			$_SESSION[$table.'_id'] = $new_id;

			_base::commit_transaction();

			_base::put_sys_oper(__METHOD__, 'save', $_SESSION['table_edit'], $_SESSION[$table.'_id']);
		}

		function warehouse_delete () {
		 	if (!_base::CheckAccess('warehouse_delete')) return;

			// warehouse_id
			$id = intVal($_REQUEST['p1']);

			if ($_POST{'process'} == 'delete' && $id) {
				if (_base::check_used_id('aviso', $id, 'warehouse_id')) {
					$message = '"'.$this->smarty->getConfigVars('table_'.$_SESSION['table_edit']).'" id:'.$id.' е използван и не може да се изтрие';
					_base::show_error($message);
				}

				$sql_query = "DELETE FROM warehouse WHERE warehouse_id = $id";
				_base::execute_sql($sql_query);

				unset($_SESSION{'warehouse_id'});
				_base::put_sys_oper(__METHOD__, 'delete', $_SESSION['table_edit'], $id);
			}
		}


		function w_group () {
		 	if (!_base::CheckAccess('w_group')) return;
			$_SESSION['main_menu'] = 'configuration';
			$_SESSION['sub_menu'] = 'w_group';
			$this->nomen_list_json($_SESSION['sub_menu'], "select * from view_w_group order by w_group_name");
			_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
		}

		function w_group_edit () {
		 	if (!_base::CheckGrant('w_group_view'))
				if (!_base::CheckAccess('w_group_edit')) return;

			$id = intVal($_REQUEST['p1']);

			$data = _base::nomen_list_edit('w_group', $id, true);

			$this->smarty->assign ('data', $data);
			$_SESSION['w_group_id'] = $id;
			$_SESSION['table_edit'] = 'w_group';
			
			_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['table_edit'], $id);
		}

		function w_group_save () {
		 	if (!_base::CheckAccess('w_group_edit')) return;

			$id = intVal($_REQUEST['p1']);
			$table = 'w_group';

			_base::start_transaction();
			$query = new ExecQuery($table);
			$query->AddParam($table.'_name');
			$query->AddParam('w_group_address');
			$query->AddParam('is_active', 'c');
			if ($id != 0) {
				$query->update([$table."_id" => $id]);
				$new_id = $id;
			}
			else
				$new_id = $query->insert();
			unset($query);
			$_SESSION[$table.'_id'] = $new_id;

			_base::commit_transaction();

			_base::put_sys_oper(__METHOD__, 'save', $_SESSION['table_edit'], $_SESSION[$table.'_id']);
		}

		function w_group_delete () {
		 	if (!_base::CheckAccess('w_group_delete')) return;

			// w_group_id
			$id = intVal($_REQUEST['p1']);

			if ($_POST{'process'} == 'delete' && $id) {
				if (_base::check_used_id('warehouse', $id, 'w_group_id')) {
					$message = '"'.$this->smarty->getConfigVars('table_'.$_SESSION['table_edit']).'" id:'.$id.' е използван и не може да се изтрие';
					_base::show_error($message);
				}

				$sql_query = "DELETE FROM w_group WHERE w_group_id = $id";
				_base::execute_sql($sql_query);

				unset($_SESSION{'w_group_id'});
				_base::put_sys_oper(__METHOD__, 'delete', $_SESSION['table_edit'], $id);
			}
		}



		function org () {
		 	if (!_base::CheckAccess('org')) return;
			$_SESSION['main_menu'] = 'configuration';
			$_SESSION['sub_menu'] = 'org';
			_base::set_table_edit_AccessRights($_SESSION['sub_menu']);
			_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
		}
		function org_ajax () {
		 	if (!_base::CheckAccess('org')) return;
			$order_by = 'org_name';
			$this->ajax_list("select * from view_org order by org_name");
		}

		function org_edit () {
		 	if (!_base::CheckGrant('org_view'))
				if (!_base::CheckAccess('org_edit')) return;

			$id = intVal($_REQUEST['p1']);

			$data = _base::nomen_list_edit('org', $id, true);

			$this->smarty->assign ('data', $data);
			$_SESSION['org_id'] = $id;
			$_SESSION['table_edit'] = 'org';
			
			// Списъка от банкови сметки
			$data_line = array();
			$query_result = _base::get_query_result("select * from org_metro WHERE org_id = $id order by org_metro_id");
			while ($query_data = _base::sql_fetch_assoc($query_result))
				$data_line[] = $query_data + array('id' => $query_data['org_metro_id'], 'real_id' => $query_data['org_metro_id']);
			_base::sql_free_result($query_result);
			$this->smarty->assign ('data_line', json_encode($data_line, JSON_UNESCAPED_UNICODE));

			// Един празен ред като Object ( JSON )
			$query_result = _base::get_query_result("select * from org_metro where 1=0");
			$empty_line = _base::sql_get_empty_assoc($query_result);
			// Добавяне на ширините на текстовите полета
			_base::sql_add_field_width($query_result, $empty_line);
			_base::sql_free_result($query_result);
			$this->smarty->assign ('empty_line', json_encode($empty_line, JSON_UNESCAPED_UNICODE));

			_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['table_edit'], $id);
		}

		function org_save () {
		 	if (!_base::CheckAccess('org_edit')) return;

			$id = intVal($_REQUEST['p1']);
			$table = 'org';

			_base::start_transaction();
			$query = new ExecQuery($table);
			$query->AddParam($table.'_name');
			$query->AddParam('org_address');
			$query->AddParam('org_contact');
			$query->AddParam('org_phone');
			$query->AddParam('org_email');
			$query->AddParam('org_note');
			$query->AddParam('org_ns_plt_eur', 'n', 0);
			$query->AddParam('org_ns_plt_chep', 'n', 0);
			$query->AddParam('org_ns_plt_other', 'n', 0);
			$query->AddParam('is_active', 'c');
			if ($id != 0) {
				$query->update([$table."_id" => $id]);
				$new_id = $id;
			}
			else
				$new_id = $query->insert();
			unset($query);
			$_SESSION[$table.'_id'] = $new_id;


			// Изтриване от org_metro
			// Ако няма никакви редове, то deleted_org_metro е празно
			$deleted_line = $_POST['deleted_org_metro'];
			if ($deleted_line) {
				// deleted_line - array['org_metro_id' => org_metro_id]
				$deleted_line = json_decode($deleted_line, true);
				foreach($deleted_line as $org_metro_id) {
					$sql_query = "delete from org_metro where (org_metro_id = $org_metro_id)";
					_base::execute_sql($sql_query);
				}
			}

			// Запис в org_metro
			$data_line = $_POST['org_metro'];
			if ($data_line) {
				// data_line - array['org_metro_id' => array[<field_name> => <value>]]
				$data_line = json_decode($data_line, true);
				foreach($data_line as $org_metro_id => $line) {
					// За новите редове, $org_metro_id е отрицателно число
					// AddParam ще добави параметъра, само ако е го има в масива
					$query = new ExecQuery('org_metro', $line);
					$query->AddParamExt('org_id', $new_id, 'n', 0);
					$query->AddParam('org_metro_code');

					// Ако line['real_id'] == '0', то е нов ред
					if ($line['real_id'])
						$query->update(["org_metro_id" => $line['org_metro_id']]);
					else
						$query->insert();
					unset($query);
				}
			} // data_line

			_base::commit_transaction();
			_base::put_sys_oper(__METHOD__, 'save', $_SESSION['table_edit'], $_SESSION[$table.'_id']);
		}

		function org_delete () {
		 	if (!_base::CheckAccess('org_delete')) return;

			// org_id
			$id = intVal($_REQUEST['p1']);

			if ($_POST{'process'} == 'delete' && $id) {
				if (_base::check_used_id('aviso', $id, 'org_id')) {
					$message = '"'.$this->smarty->getConfigVars('table_'.$_SESSION['table_edit']).'" id:'.$id.' е използван и не може да се изтрие';
					_base::show_error($message);
				}
				if (_base::check_used_id('pltorg', $id, 'org_id')) {
					$message = '"'.$this->smarty->getConfigVars('table_'.$_SESSION['table_edit']).'" id:'.$id.' е използван и не може да се изтрие';
					_base::show_error($message);
				}

				_base::start_transaction();
				
				$sql_query = "DELETE FROM org WHERE org_id = $id";
				_base::execute_sql($sql_query);

				$sql_query = "DELETE FROM org_metro WHERE org_id = $id";
				_base::execute_sql($sql_query);

				$sql_query = "DELETE FROM user WHERE org_id = $id";
				_base::execute_sql($sql_query);

				_base::commit_transaction();

				unset($_SESSION{'org_id'});
				_base::put_sys_oper(__METHOD__, 'delete', $_SESSION['table_edit'], $id);
			}
		}



		function shop () {
		 	if (!_base::CheckAccess('shop')) return;
			$_SESSION['main_menu'] = 'configuration';
			$_SESSION['sub_menu'] = 'shop';
			$this->nomen_list_json($_SESSION['sub_menu'], "select * from view_shop order by shop_name");
			_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
		}

		function shop_edit () {
		 	if (!_base::CheckGrant('shop_view'))
				if (!_base::CheckAccess('shop_edit')) return;

			$id = intVal($_REQUEST['p1']);

			$data = _base::nomen_list_edit('shop', $id, true);

			$this->smarty->assign ('data', $data);
			$_SESSION['shop_id'] = $id;
			$_SESSION['table_edit'] = 'shop';
			
			_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['table_edit'], $id);
		}

		function shop_save () {
		 	if (!_base::CheckAccess('shop_edit')) return;

			$id = intVal($_REQUEST['p1']);
			$table = 'shop';

			_base::start_transaction();
			$query = new ExecQuery($table);
			$query->AddParam($table.'_name');
			$query->AddParam('shop_address');
			$query->AddParam('shop_code');
			$query->AddParam('is_active', 'c');
			if ($id != 0) {
				$query->update([$table."_id" => $id]);
				$new_id = $id;
			}
			else
				$new_id = $query->insert();
			unset($query);
			$_SESSION[$table.'_id'] = $new_id;

			_base::commit_transaction();

			_base::put_sys_oper(__METHOD__, 'save', $_SESSION['table_edit'], $_SESSION[$table.'_id']);
		}

		function shop_delete () {
		 	if (!_base::CheckAccess('shop_delete')) return;

			// shop_id
			$id = intVal($_REQUEST['p1']);

			if ($_POST{'process'} == 'delete' && $id) {
				if (_base::check_used_id('pltshop', $id, 'shop_id')) {
					$message = '"'.$this->smarty->getConfigVars('table_'.$_SESSION['table_edit']).'" id:'.$id.' е използван и не може да се изтрие';
					_base::show_error($message);
				}
				if (_base::check_used_id('aviso_line', $id, 'shop_id')) {
					$message = '"'.$this->smarty->getConfigVars('table_'.$_SESSION['table_edit']).'" id:'.$id.' е използван и не може да се изтрие';
					_base::show_error($message);
				}

				_base::start_transaction();

				$sql_query = "DELETE FROM shop WHERE shop_id = $id";
				_base::execute_sql($sql_query);

				_base::commit_transaction();

				unset($_SESSION{'shop_id'});
				_base::put_sys_oper(__METHOD__, 'delete', $_SESSION['table_edit'], $id);
			}
		}



		function user () {
		 	if (!_base::CheckAccess('user')) return;
			$_SESSION['main_menu'] = 'configuration';
			$_SESSION['sub_menu'] = 'user';
			_base::set_table_edit_AccessRights('user');
			_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
		}
		function user_ajax () {
		 	if (!_base::CheckAccess('user')) return;
			$this->ajax_list("select * from view_user order by org_name,user_name");
		}

		function user_edit () {
		 	if (!_base::CheckAccess('user_edit')) return;

			$id = intVal($_REQUEST['p1']);

			// Списъци за select
			// get_select_list($table, $smarty_var = null, $order_by = null, $where = null) {
			_base::get_select_list('org');
			_base::get_select_list('user_role');
			_base::get_select_list('w_group');

			$data = _base::nomen_list_edit('user', $id, true);
			$this->smarty->assign ('data', $data);

			_base::get_select_list('warehouse', null, null, 'where w_group_id = '.intVal($data['w_group_id']));

			$_SESSION['user_id'] = $id;
			$_SESSION['table_edit'] = 'user';

			_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['table_edit'], $id);
		}

		function user_profil_edit () {
			$id = $_SESSION['userdata']['user_id'];
		 	//if (!$id) return;

			// Списъци за select
			// get_select_list($table, $smarty_var = null, $order_by = null, $where = null) {
			_base::get_select_list('user_role');
			_base::get_select_list('w_group');

			$data = _base::nomen_list_edit('user', $id, true);
			$data['allow_edit'] = true;
			$data['allow_delete'] = false;
			$this->smarty->assign ('data', $data);

			_base::get_select_list('warehouse', null, null, 'where w_group_id = '.intVal($data['w_group_id']));

			$_SESSION['user_id'] = $id;
			$_SESSION['table_edit'] = 'user';

			_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['table_edit'], $id);
		}

		function user_save () {
			// Ако записа идва от user_profil_edit, тогава да си го записва
			$is_user_profil_edit = $_POST['user_profil_edit'];
			if (!$is_user_profil_edit)
				if (!_base::CheckAccess('user_edit')) return;

			$id = intVal($_REQUEST['p1']);
			$table = 'user';

			if ($is_user_profil_edit and !$id)
				return;

			// Проверка дали няма въведен вече такъв потребител
			if (!$this->check_unique_user($id))
				return;

			_base::start_transaction();
			$query = new ExecQuery($table);
			if (DB_FIREBIRD)
				$query->table = '"USER"';
			$query->AddParam($table.'_name');
			$query->AddParam('user_password');
			if (!$is_user_profil_edit)
				$query->AddParam('user_role_id', 'n');
			if (!$is_user_profil_edit)
				$query->AddParam('org_id', 'n');
			$query->AddParam('w_group_id', 'n');
			$query->AddParam('warehouse_id', 'n');
			$query->AddParam('aviso_driver_name');
			$query->AddParam('aviso_driver_phone');

			$query->AddParam('user_full_name');
			$query->AddParam('user_phone');
			$query->AddParam('user_email');
			if (!$is_user_profil_edit)
				$query->AddParam('is_active', 'c');
			if ($id != 0) {
				$query->update([$table."_id" => $id]);
				$new_id = $id;
			}
			else
				$new_id = $query->insert();
			unset($query);
			_base::commit_transaction();
			$_SESSION[$table.'_id'] = $new_id;

			_base::put_sys_oper(__METHOD__, 'save', $_SESSION['table_edit'], $_SESSION[$table.'_id']);

			// Ако това е текущия потребител
			if ($new_id == $_SESSION['userdata']['user_id']) {
				$sql_query = "SELECT * FROM view_user WHERE user_id = $new_id";
				$query_result = _base::get_query_result($sql_query);
				$query_data = _base::sql_fetch_assoc($query_result);
				_base::sql_free_result($query_result);
				if ($query_data) {
					$query_data['logon_id'] = $_SESSION['userdata']['logon_id'];
					$_SESSION['userdata'] = $query_data;

					$sql_query = "SELECT grants
						FROM user_role 
						WHERE user_role_id = ". $_SESSION['userdata']['user_role_id'];
					$query_result = _base::get_query_result($sql_query);
					$grants = _base::sql_fetch_assoc($query_result);
					_base::sql_free_result($query_result);
					$_SESSION['userdata']['grants'] = json_decode($grants['grants'], true);;
				}
			}
		}

		function user_delete () {
		 	if (!_base::CheckAccess('user_delete')) return;

			$id = intVal($_REQUEST['p1']);

			if ($_POST{'process'} == 'delete' && $id) {
				$sql_query = "DELETE FROM user WHERE user_id = $id";
				_base::execute_sql($sql_query);
				unset($_SESSION['user_id']);
				_base::put_sys_oper(__METHOD__, 'delete', $_SESSION['table_edit'], $id);
			}
		}

		function check_unique_user ($user_id = null) {
			// Проверка за уникално user_name, org_id в таблицата user
			// Ако е подаден параметър $user_id, то се извиква локално, иначе е от формата за въвеждане
			// Ако има друг потребител, връща идентификатора му
			if (!isset($user_id))
				$user_id = intVal($_REQUEST['p1']);
			
			if (!$_POST['user_name']) return true;

			$org_id = intVal($_POST['org_id']);
			// Ако потребителя няма право да вижда всички Доставчици
			if (!$_SESSION['userdata']['grants']['view_all_suppliers'])
				$org_id = intVal($_SESSION['userdata']['org_id']);
			$user_name = _base::escape_string($_POST['user_name']);

			$sql_query = "SELECT user_id
				FROM user
				WHERE org_id = $org_id and user_name = '$user_name' and user_id+0 <> $user_id";
			$query_result = _base::get_query_result($sql_query);
			$temp = _base::sql_fetch_assoc($query_result);
			_base::sql_free_result($query_result);
			if ($temp) {
				echo $this->smarty->getConfigVars('error_duplicate_user').' (id: '.$temp['user_id'].')';
				return false;
			}

			return true;
		}

		function send_test_mail() {
			if (!_base::CheckAccess('user_edit')) return;
			// user_id
			$user_id = intVal($_REQUEST['p1']);
			if (!$user_id) return;
			// Ако -1, то е изпращане на мейл при нов потребител
			if ($user_id < 0)
				$user_id = $_SESSION['user_id'];

			$data_mail = _base::nomen_list_edit('user', $user_id, true, null, null, false);

			if ($data_mail['user_email']) {
				for($i=1; $i<=1; $i++) {
					if (!_base::send_user_mail($data_mail, false)) return;
				}
				/*
				_base::start_transaction();
				$sql_query = "UPDATE `user` set email_sended = '1'"
					. PHP_EOL . " where user_id = $user_id";
				_base::execute_sql($sql_query);
				_base::commit_transaction();
				*/
			}
		}

		function ajax_gen_password () {
			echo _base::random_password();
		}


		function user_role () {
		 	if (!_base::CheckAccess('user')) return;
			$_SESSION['main_menu'] = 'configuration';
			$_SESSION['sub_menu'] = 'user_role';
			$this->nomen_list_json($_SESSION['sub_menu'], "select * from user_role order by user_role_name");
			$this->smarty->assign('allow_edit', ($_SESSION['userdata']['grants']['user_edit'] == '1'));
			$this->smarty->assign('allow_view', ($_SESSION['userdata']['grants']['user_edit'] == '1') or ($_SESSION['userdata']['grants']['user_view'] == '1'));
			_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
		}

		function user_role_edit () {
		 	if (!_base::CheckAccess('user_edit')) return;

			$id = intVal($_REQUEST['p1']);

			//$data = _base::nomen_list_edit('user_role', $id);
			$sql_query = "SELECT * FROM user_role WHERE user_role_id = $id";
			$query_result = _base::get_query_result($sql_query);
			$data = _base::sql_fetch_assoc($query_result);
			_base::sql_free_result($query_result);
			if (!$id)
				$data['allow_delete'] = false;
			else
			if ($_SESSION['userdata']['grants']['user_delete'])
				$data['allow_delete'] = true;
			else
				$data['allow_delete'] = false;
			if ($_SESSION['userdata']['grants']['user_edit'])
				$data['allow_edit'] = true;
			else
				$data['allow_edit'] = false;

			$data['id'] = $id;
			$data['user_role_name'] = htmlspecialchars($data['user_role_name']);
			$data['grants'] = json_decode($data['grants'], true);
			$this->smarty->assign('data', $data);
			$_SESSION['user_role_id'] = $id;
			$_SESSION['table_edit'] = 'user_role';

			_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['table_edit'], $id);
		}

		function user_role_save () {
		 	if (!_base::CheckAccess('user_edit')) return;

			$id = intVal($_REQUEST['p1']);
			$table = 'user_role';

			_base::start_transaction();

			$query = new ExecQuery($table);
			$query->AddParam($table.'_name');
			$query->AddParam('grants');
			$query->AddParam('is_active', 'c');
			if ($id != 0) {
				$query->update([$table."_id" => $id]);
				$new_id = $id;
			}
			else
				$new_id = $query->insert();
			unset($query);

			_base::commit_transaction();
			$_SESSION[$table.'_id'] = $new_id;

			_base::put_sys_oper(__METHOD__, 'save', $_SESSION['table_edit'], $_SESSION[$table.'_id']);

			// Ако това е текущия потребител
			if ($new_id == $_SESSION['userdata']['user_role_id']) {
				$sql_query = "SELECT grants
					FROM user_role 
					WHERE user_role_id = ". $_SESSION['userdata']['user_role_id'];
				$query_result = _base::get_query_result($sql_query);
				$grants = _base::sql_fetch_assoc($query_result);
				_base::sql_free_result($query_result);
				$_SESSION['userdata']['grants'] = json_decode($grants['grants'], true);;
			}
		}

		function user_role_delete () {
		 	if (!_base::CheckAccess('user_delete')) return;

			$id = intVal($_REQUEST['p1']);

			if ($_POST{'process'} == 'delete' && $id) {
				if (_base::check_used_id('user', $id, 'user_role_id')) {
					$message = '"'.$this->smarty->getConfigVars('table_'.$_SESSION['table_edit']).'" id:'.$id.' е използван и не може да се изтрие';
					_base::show_error($message);
				}

				$sql_query = "DELETE FROM user_role WHERE user_role_id = $id";
				_base::execute_sql($sql_query);
				unset($_SESSION['user_role_id']);
				_base::put_sys_oper(__METHOD__, 'delete', $_SESSION['table_edit'], $id);
			}
		}


		function calendar () {
		 	if (!_base::CheckAccess('calendar')) return;
			$_SESSION['main_menu'] = 'configuration';
			$_SESSION['sub_menu'] = 'calendar';
			$this->nomen_list_json($_SESSION['sub_menu'], "select * from view_calendar order by calendar_date");
			_base::put_sys_oper(__METHOD__, 'browse', $_SESSION['sub_menu'], 0);
		}

		function calendar_edit () {
		 	if (!_base::CheckAccess('calendar_edit')) return;

			$id = intVal($_REQUEST['p1']);

			$data = _base::nomen_list_edit('calendar', $id);
			if (!$id) {
				$data['calendar_is_working_day'] = '2';
			}
			$this->smarty->assign ('data', $data);
			$_SESSION['calendar_id'] = $id;
			$_SESSION['table_edit'] = 'calendar';

			_base::put_sys_oper(__METHOD__, 'edit', $_SESSION['table_edit'], $id);
		}

		function calendar_save () {
		 	if (!_base::CheckAccess('calendar_edit')) return;

			$id = intVal($_REQUEST['p1']);
			$table = 'calendar';
			
			$week_day = date('w', strtotime($_POST['calendar_date']));
			$calendar_is_working_day = $_POST['calendar_is_working_day'];
			
			// Съботи и недели не могат да се правят почивни
			if (($week_day == 0 or $week_day == 6) and $calendar_is_working_day === '2') return;
			// Понеделник - Петък не могат да се правят работни
			if (($week_day >= 1 and $week_day <= 5) and $calendar_is_working_day == '1') return;

			_base::start_transaction();

			$query = new ExecQuery($table);
			$query->AddParam('calendar_date');
			$query->AddParam('calendar_is_working_day', 'c');
			if ($id != 0) {
				$query->update([$table."_id" => $id]);
				$new_id = $id;
			}
			else
				$new_id = $query->insert();
			unset($query);

			_base::commit_transaction();
			$_SESSION[$table.'_id'] = $new_id;

			_base::put_sys_oper(__METHOD__, 'save', $_SESSION['table_edit'], $_SESSION[$table.'_id']);
		}

		function calendar_delete () {
		 	if (!_base::CheckAccess('calendar_delete')) return;

			$id = intVal($_REQUEST['p1']);

			if ($_POST{'process'} == 'delete' && $id) {
				$sql_query = "DELETE FROM calendar WHERE calendar_id = $id";
				_base::execute_sql($sql_query);
				unset($_SESSION['calendar_id']);
				_base::put_sys_oper(__METHOD__, 'delete', $_SESSION['table_edit'], $id);
			}
		}


	}
?>
