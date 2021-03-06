<?php
	
	function nl2br2($string) {
		return str_replace(array("\r\n", "\r", "\n"), "<br />", $string);
	} 
//print nl2br2 (print_r($sql_query, true) . PHP_EOL);

	class _base {
		public static $forbidden = true;

		public static $vat_percent = 19;
		public static $rent_soll_2_space_rent = 0.95;

		// За да не се подават като параметри във функциите, се задават направо в lib_site.php
		public static $smarty;
		// Конекцията към MySQL
		public static $mysqli;
		// Конекцията към Firebird
		public static $dbMain;

		// Брояч колко пъти съм се опитал да стартирам Write Transaction
		private static $transaction_count = 0;
		public static $ReadTr = false;
		public static $WriteTr = false;

		// Дали е в режим на грешка, за да не стават рекурсии
		private static $error_state = false;



		public static function CheckAccess($user_grant_name, $do_redirect = true) {
			// Проверка за разрешен достъп до операция user_grant_name
			
			// Ако идва от shortcut, а потребителя не се е логнал
			// Ако не се е логнал, да се логне и пак да го прати на исканото URL
			if (!$_SESSION['loggedin']) {
				$_SESSION['display_path'] = 'main_menu/deflt.tpl';
				//$_SESSION['relogin_url'] = "http://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
				$_SESSION['relogin_url'] = "$_SERVER[REQUEST_URI]";
				return false;
			}
			if ($_SESSION['userdata']['grants'][$user_grant_name]) {
				unset($_SESSION['display_text']);
				return true;
			} else {
				if ($do_redirect) {
					$_SESSION['display_path'] = 'main_menu/deflt.tpl';
					$_SESSION['display_text'] = self::$smarty->getConfigVars('access_denied');
				} else {
					echo self::$smarty->getConfigVars('access_denied');
				}
				return false;
			}
		}
		
		public static function CheckGrant($user_grant_name) {
			// Проверка за разрешен достъп до операция user_grant_name
			
			if ($_SESSION['userdata']['grants'][$user_grant_name])
				return true;
			else {
				return false;
			}
		}
		
		public static function random_password( $length = 9 ) {
			//$chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_-=+;:,.?";
			$chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
			$password = substr( str_shuffle( $chars ), 0, $length );
			return $password;
		}
		
		
		// Конвертира 25.01.2015 в 2015-01-25 за запис в MySql
		public static function StrToMySqlDate(&$s) {
			// ама проверява дали не е вече в правилния формат
			
			// Дали има и час 12:30
			if ($t_pos = strpos($s, ' ')) {
				$t = ' '.substr($s, $t_pos+1);
				$s = substr($s, 0, $t_pos);
			} else
				$t = '';
			if (!$s or $s === 'null') $s = null;
			elseif ($s == '00.00.0000') $s = null;
			elseif ($s == '00/00/0000') $s = null;
			elseif ($s == '0000-00-00') $s = null;
			elseif (strpos($s, '-') === false) {
				$a = explode ($_SESSION['lang']['dateSep'], $s);
				$s = $a[2].'-'.$a[1].'-'.$a[0].$t;
			}
			else
				$s = $s.$t;
		}

		public static function Str2MySqlDate($s) {
			_base::StrToMySqlDate($s);
			return $s;
		}

		// Конвертира 2015-01-25 в 25.01.2015
		public static function MySqlDateToStr(&$s) {
			// Дали има и час 12:30
			if ($t_pos = strpos($s, ' ')) {
				$t = ' '.substr($s, $t_pos+1);
				$s = substr($s, 0, $t_pos);
			} else
				$t = '';
			if (!$s or $s === 'null') $s = null;
			elseif ($s == '0000-00-00') $s = null;
			else {
				$a = explode ("-", $s);
				$sep = $_SESSION['lang']['dateSep'];
				$s = $a[2].$sep.$a[1].$sep.$a[0].$t;
			}
		}

		public static function MySqlDate2Str($s) {
			_base::MySqlDateToStr($s);
			return $s;
		}


		public static function set_table_edit_AccessRights($table) {
			$_SESSION['table_edit'] = $table;
			// Права за добавяне и корекция allow_edit, allow_view
			self::$smarty->assign('allow_edit', ($_SESSION['userdata']['grants'][$_SESSION['table_edit'].'_edit'] == '1'));
			self::$smarty->assign('allow_view', ($_SESSION['userdata']['grants'][$_SESSION['table_edit'].'_edit'] == '1') or ($_SESSION['userdata']['grants'][$_SESSION['table_edit'].'_view'] == '1'));
		}


		public static function nomen_list($sql_query, $field_id = null) {
			// Прави стандартно попълване на $data за <table>_list

			$query_result = _base::get_query_result($sql_query);
			// Ако не е подадено името на полето за id, взимам първото поле
			if (!$field_id) {
				$fields = _base::get_fields_name($query_result);
				$field_id = $fields[0];
			}

			$data = array();
			while ($query_data = _base::sql_fetch_assoc($query_result)) {
				$data[] = $query_data + array('id' => $query_data[$field_id]);
			}
			_base::sql_free_result($query_result);

			return $data;
		}

		public static function echo_nomen_list_partial($sql_query, $field_id = null) {
			$time = -microtime(true);
			$query_result = _base::get_query_result($sql_query);

			$fields = _base::get_fields_name($query_result);
			$fields[] = 'id';
			// Ако не е подадено името на полето за id, взимам първото поле
			if ($field_id)
				$indexOfID = array_search($field_id, $fields);
			else
				$indexOfID = 0;
			
			echo '{'. 
				substr(json_encode(array('fields' => $fields), JSON_UNESCAPED_UNICODE),1,-1)
				.',"data":[';

			$data = array();
			$first_echo = true;
			while ($query_data = _base::sql_fetch_row($query_result)) {
				$query_data[] = $query_data[$indexOfID];
				$data[] = $query_data;
				if (count($data) >= 100) {
					echo ($first_echo ? '':',') . substr(json_encode($data, JSON_UNESCAPED_UNICODE),1,-1);
					$data = array();
					$first_echo = false;
				}
			}
			_base::sql_free_result($query_result);
			$time += microtime(true);
			if (count($data)) {
				echo ($first_echo ? '':',') . substr(json_encode($data, JSON_UNESCAPED_UNICODE),1,-1);
			}
			echo '],'. substr(json_encode(array('execution_time' => number_format($time*1000,3)), JSON_UNESCAPED_UNICODE),1,-1) . '}';
		}

		public static function nomen_list_edit($table, $id, $is_view = false, $field_id = null, $add_select = null, $do_htmlspecialchars = true) {
			// Прави стандартно попълване на $data за <table>_edit
			// Единствено от configuration/user_edit() се вика с $do_htmlspecialchars = false

			$id = intVal($id);
			if (!$field_id) $field_id = $table.'_id';
			if ($add_select)
				$add_select = ', ' . $add_select;
			else
				$add_select = '';

			if (!$is_view)
				$sql_query = "SELECT {$table}.* $add_select FROM {$table} WHERE $field_id = $id";
			else
				$sql_query = "SELECT view_{$table}.* $add_select FROM view_{$table} WHERE $field_id = $id";
			$query_result = _base::get_query_result($sql_query);
			if ($id)
				$data = _base::sql_fetch_assoc($query_result);
			else
				$data = _base::sql_get_empty_assoc($query_result);
			// Добавяне на ширините на текстовите полета
			_base::sql_add_field_width($query_result, $data);
			_base::sql_free_result($query_result);

			if ($data['cr_user_id'] and !array_key_exists('cr_user_name', $data))
				$data['cr_user_name'] = _base::get_lookup_field('user', 'user_id', $data['cr_user_id'], 'user_name');
			if ($data['mo_user_id'] and !array_key_exists('mo_user_name', $data))
				$data['mo_user_name'] = _base::get_lookup_field('user', 'user_id', $data['mo_user_id'], 'user_name');

			if ($_SESSION['userdata']['grants'][$table.'_delete'])
				$data['allow_delete'] = true;
			else
				$data['allow_delete'] = false;

			if (!$id) {
				$data['allow_delete'] = false;
				// Ако има поле is_active, то да е включено по-подразбиране
				if (array_key_exists('is_active', $data))
					$data['is_active'] = '1';
			}

			if ($_SESSION['userdata']['grants'][$table.'_edit'])
				$data['allow_edit'] = true;
			else
				$data['allow_edit'] = false;

			// escape special chars
			$data['id'] = $id;
			if ($do_htmlspecialchars)
				foreach($data as $key => $value)
					if(is_string($value))
						$data[$key] = htmlspecialchars($value);
			$_SESSION['table_edit'] = $table;
			return $data;
		}

		public static function nomen_list_refresh($sql_query, $id) {
			// Прави стандартно връщане на данните от един ред
			// извиква се от PHP процедурите
			// configuration->list_refresh

			$query_result = _base::get_query_result($sql_query);
			$data = _base::sql_fetch_assoc($query_result, false);
			_base::sql_free_result($query_result);
			$data['id'] = $id;
			return $data;
		}


		// Добавя условие за филтриране по org_id
		public static function add_filter_org(&$where) {
			// Ако потребителя няма право да вижда всички Доставчици
			if (!$_SESSION['userdata']['grants']['view_all_suppliers']) {
				if (!$where) 
					$where = "WHERE (org_id = {$_SESSION['userdata']['org_id']})";
				else
					$where .= " and (org_id = {$_SESSION['userdata']['org_id']})";
			}
		}


		public static function get_select_list_sql($sql_query, $smarty_var) {
			// Списъка от site, company, ...

			$query_result = _base::get_query_result($sql_query);
			$temp[0] = '&nbsp;';
			while ($query_data =  _base::sql_fetch_row($query_result)) {
				$temp[$query_data[0]] = $query_data[1];
			}
			_base::sql_free_result($query_result);
			if ($smarty_var)
				self::$smarty->assign ($smarty_var, $temp);
			return $temp;
		}

		public static function get_select_list($table, $smarty_var = null, $order_by = null, $where = null, $field_name = null) {
			// Списъка от site, company, ...
			if (!$order_by) $order_by = $table.'_name';
			if (!$field_name) $field_name = $table.'_name';
			if (!$smarty_var) $smarty_var = 'select_'.$table;

			$sql_query = "select {$table}_id as id, $field_name as name from $table ";

			// Ако се иска org и се филтрира по org_id
			if ($table == 'org') {
				_base::add_filter_org($where);
			}

			if ($where) $sql_query .= $where;
			$sql_query .= " ORDER BY $order_by";
			$query_result = _base::get_query_result($sql_query);
			$temp[0] = '&nbsp;';
			while ($query_data = _base::sql_fetch_assoc($query_result)) {
				$temp[$query_data['id']] = htmlspecialchars($query_data['name']);
			}
			_base::sql_free_result($query_result);
			self::$smarty->assign ($smarty_var, $temp);
			return $temp;
		}

		public static function get_select_list_ajax($table, $order_by = null, $where = null, $field_name = null, $field_id = null, $add_select = null) {
			// Това се вика само от class get_ajax
			if (!$order_by) $order_by = $table.'_name';
			if (!$field_name) $field_name = $table.'_name';
			if (!$field_id) $field_id = $table.'_id';
			if ($add_select)
				$add_select = ', ' . $add_select;
			else
				$add_select = '';

			$sql_query = "select $field_id as id, $field_name as name $add_select from $table ";

			if ($where) $sql_query .= $where;
			$sql_query .= " ORDER BY $order_by";
			$query_result = _base::get_query_result($sql_query);
			$temp[0] = array('id' => '0', 'name' => '&nbsp;');
			while ($query_data = _base::sql_fetch_assoc($query_result, false)) {
				$temp[] = $query_data;
			}
			_base::sql_free_result($query_result);
			return $temp;
		}


		public static function get_select_warehouse_type($smarty_var = null) {
			if (!$smarty_var) $smarty_var = 'select_warehouse_type';
			$temp['0'] = '&nbsp;';
			$temp['1'] = self::$smarty->getConfigVars('warehouse_type_1');
			$temp['2'] = self::$smarty->getConfigVars('warehouse_type_2');
			$temp['3'] = self::$smarty->getConfigVars('warehouse_type_3');

			self::$smarty->assign ($smarty_var, $temp);
			return $temp;
		}

		public static function get_select_aviso_status($smarty_var = null, $for_edit = false) {
			if (!$smarty_var) $smarty_var = 'select_aviso_status';
			if (!$for_edit)
				$temp[-1] = '&nbsp;';
			$temp['0'] = self::$smarty->getConfigVars('aviso_status_0');
			$temp['3'] = self::$smarty->getConfigVars('aviso_status_3');
			$temp['7'] = self::$smarty->getConfigVars('aviso_status_7');
			$temp['8'] = self::$smarty->getConfigVars('aviso_status_8');
			$temp['9'] = self::$smarty->getConfigVars('aviso_status_9');
			if (!$for_edit) {
				$temp['03'] = self::$smarty->getConfigVars('aviso_status_0').'+'.self::$smarty->getConfigVars('aviso_status_3');
				$temp['37'] = self::$smarty->getConfigVars('aviso_status_3').'+'.self::$smarty->getConfigVars('aviso_status_7');
			}

			self::$smarty->assign ($smarty_var, $temp);
			return $temp;
		}



		public static function get_lookup_field($table, $field_id, $id, $field_name) {
			if ($id != 0) {
				if (self::$mysqli)
					$sql_query = "SELECT `$field_name` FROM `$table` WHERE `$field_id` = $id";
				else
					$sql_query = 'SELECT "'.strtoupper($field_name).'" FROM "'.strtoupper($table).'" WHERE "'.strtoupper($field_id).'" = '.$id;
				$query_result = _base::get_query_result($sql_query);
				$data = _base::sql_fetch_assoc($query_result);
				_base::sql_free_result($query_result);
				// escape special chars
				//$result = htmlspecialchars($data[$field_name]);
				$result = $data[$field_name];
			} else {
				$result = null;
			}
			return $result;
		}

		public static function get_config($config_name) {
			if ($config_name != '') {
				$sql_query = "SELECT config_value FROM config WHERE config_name = '$config_name'";
				$data = _base::select_sql($sql_query);
				// escape special chars
				$result = htmlspecialchars($data['config_value']);
			} else {
				$result = null;
			}
			return $result;
		}



		public static function put_sys_oper($oper_name, $oper_type, $table_name, $table_id, $note = null) {
			if (defined('DONT_PUT_SYS_OPER') and DONT_PUT_SYS_OPER) return true;

			$user_id = $_SESSION['userdata']['user_id'];
			$logon_id = $_SESSION['userdata']['logon_id'];
			$curr_time = gmdate("Y-m-d H:i:s");
			_base::start_transaction();
			$query = new ExecQuery('sys_oper');
			$query->add_cr_mo = false;
			$query->AddParamExt('user_id', $user_id, 'n', 0);
			$query->AddParamExt('logon_id', $logon_id, 'n', 0);
			$query->AddParamExt('oper_date', $curr_time, 'd', null);
			$query->AddParamExt('oper_name', $oper_name, 's', null);
			$query->AddParamExt('oper_type', $oper_type, 's', null);
			$query->AddParamExt('table_name', $table_name, 's', null);
			$query->AddParamExt('table_id', $table_id, 'n', 0);
			$query->AddParamExt('note', $note, 's', null);

			$new_id = $query->insert();
			_base::commit_transaction();

			return true;
		}


		public static function check_used_id($table, $id, $field1, $field2 = null, $field3 = null, $field4 = null) {
		// Проверява дали посочения $id е използван в таблица $table в полета $field1, $field2, ...
		// Връща true, ако е използвана
			$result = false;
			if ($id != 0) {
				if (!DB_FIREBIRD) {
					$sql_query = "select 1 from `$table` WHERE `$field1` = $id";
					if ($field2)
						$sql_query .= " or `$field2` = $id";
					if ($field3)
						$sql_query .= " or `$field3` = $id";
					if ($field4)
						$sql_query .= " or `$field4` = $id";
					$sql_query .= " limit 1";
				} else {
					$sql_query = 'select first 1 1 from "'.strtoupper($table).'" WHERE "'.strtoupper($field1).'" = '.$id;
					if ($field2)
						$sql_query .= ' or "'.strtoupper($field2).'" = '.$id;
					if ($field3)
						$sql_query .= ' or "'.strtoupper($field3).'" = '.$id;
					if ($field4)
						$sql_query .= ' or "'.strtoupper($field4).'" = '.$id;
				}
				$query_result = _base::get_query_result($sql_query);

				if (!DB_FIREBIRD) {
					if ($query_result->num_rows)
						$result = true;
				} else {
					// Трябва да се направи fetch, за да се разбере дали е празно
					if (ibase_fetch_row($query_result))
						$result = true;
				}
				_base::sql_free_result($query_result);
			}
			return $result;
		}

		public static function get_trace($skip_first = 0) {
			$result = '';
			$skip_first++;
			$trace = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS);
			foreach($trace as $stack) {
				if ($skip_first > 0) {
					$skip_first--;
					continue;
				}
				$result .= '  ' . basename($stack['file'])." [".$stack['line']."] => " . $stack['class']."::".$stack['function'] . PHP_EOL;
			}
			return $result;
		}

		public static function show_error($message = 'Error') {
			if (self::$error_state) exit;
			self::$error_state = true;

			if (substr($message, 0, 5) != 'Error')
				$message = 'Error'. PHP_EOL . $message;
			$message .= PHP_EOL;

			echo( nl2br2($message));

			_base::rollback_transaction();
			_base::commitReadTr();
			_base::log_in_file($message);
			exit;
		}
		public static function show_sql_error($message = 'Error') {
			if (self::$error_state) exit;
			self::$error_state = true;

			if (substr($message, 0, 5) != 'Error')
				$message = 'Error'. PHP_EOL . $message;
			if (!DB_FIREBIRD)
				$message .= PHP_EOL . PHP_EOL . mysqli_error(self::$mysqli) . PHP_EOL . PHP_EOL;
			else
				$message .= PHP_EOL . PHP_EOL . ibase_errmsg() . PHP_EOL . PHP_EOL;
			$message .= _base::get_trace(0);

			echo( nl2br2($message));
			
			// Тест за рекурсия на грешките - работи идеално
			//_base::execute_sql('insert into sys_oper1 (1)');

			_base::rollback_transaction();
			_base::commitReadTr();
			_base::log_in_file($message, false);
			exit;
		}


		public static function escape_string($s) {
			if (!DB_FIREBIRD)
				return mysqli_real_escape_string(self::$mysqli, $s);
			else
				return str_replace("'", "''", $s);
		}


		public static function startReadTr() {
			if (!self::$WriteTr and !self::$ReadTr) {
				if (!DB_FIREBIRD) {
					//self::$ReadTr = mysqli_begin_transaction(self::$mysqli, MYSQLI_TRANS_START_READ_ONLY);
					self::$ReadTr = mysqli_begin_transaction(self::$mysqli);
				} else {
					self::$ReadTr = ibase_trans(IBASE_READ | IBASE_COMMITTED | IBASE_REC_VERSION | IBASE_NOWAIT, self::$dbMain);
				}
				//_base::log_in_file('startReadTr ' . self::$ReadTr);
			}
		}
		public static function commitReadTr() {
			if (self::$ReadTr) {
				if (!DB_FIREBIRD) {
					mysqli_commit(self::$mysqli);
				} else {
					ibase_commit(self::$ReadTr);
				}
				self::$ReadTr = false;
				//_base::log_in_file('commitReadTr');
			}
		}

		public static function start_transaction() {
			//_base::log_in_file('start_transaction '.self::$transaction_count);
			// Ако няма реално стартирана WriteTr, то я стартираме, иначе само увеличаваме брояча
			if (self::$transaction_count > 0)
				self::$transaction_count++;
			else {
				// проверява се дали има стартирана Read и тя се Commit
				_base::commitReadTr();

				if (!DB_FIREBIRD) {
					mysqli_autocommit(self::$mysqli, false);
					//self::$WriteTr = mysqli_begin_transaction(self::$mysqli, MYSQLI_TRANS_START_READ_WRITE);
					self::$WriteTr = mysqli_begin_transaction(self::$mysqli);
				}
				else {
					self::$WriteTr = ibase_trans(IBASE_WRITE | IBASE_COMMITTED | IBASE_REC_VERSION | IBASE_NOWAIT, self::$dbMain);
				}
				self::$transaction_count++;
				//_base::log_in_file('real start '.self::$transaction_count, false);
			}
		}
		public static function commit_transaction() {
			//_base::log_in_file('commit_transaction '.self::$transaction_count);
			if (self::$transaction_count > 1)
				self::$transaction_count--;
			else
			if (self::$transaction_count == 1) {
				if (!DB_FIREBIRD) {
					mysqli_commit(self::$mysqli);
					mysqli_autocommit(self::$mysqli, true);
				}
				else {
					ibase_commit(self::$WriteTr);
				}
				self::$WriteTr = false;
				self::$transaction_count--;
				//_base::log_in_file('real commit '.self::$transaction_count, false);
			}
		}
		public static function rollback_transaction() {
			//_base::log_in_file('rollback_transaction '.self::$transaction_count);
			if (self::$transaction_count > 0) {
				if (!DB_FIREBIRD) {
					mysqli_rollback(self::$mysqli);
					mysqli_autocommit(self::$mysqli, true);
				}
				else {
					ibase_rollback(self::$WriteTr);
				}
				self::$WriteTr = false;
				self::$transaction_count--;
				//_base::log_in_file('real rollback '.self::$transaction_count, false);
			}
		}



		// Изпълнява подадената заявка
		public static function execute_sql($sql_query) {
			_base::start_transaction();
			if (!DB_FIREBIRD) {
				$query_result = mysqli_query(self::$mysqli, $sql_query);
				if (!$query_result) {
					_base::show_sql_error($sql_query);
				}
				while (mysqli_more_results(self::$mysqli)) {
					mysqli_next_result(self::$mysqli);
				}
			} else {
				try {
					$query_result = @ibase_query(self::$WriteTr, $sql_query);
				} catch(Exception $e) {
					_base::show_sql_error($e . PHP_EOL . $sql_query);
				}
				if (!$query_result) {
					_base::show_sql_error($sql_query);
				}
			}
			_base::commit_transaction();
			return true;
		}

		// Връща подадената select заявка като assoc array - за едноредови резултати
		public static function select_sql($sql_query, $do_htmlspecialchars = false) {
			$query_result = _base::get_query_result($sql_query);
			$query_data = _base::sql_fetch_assoc($query_result, $do_htmlspecialchars);
			_base::sql_free_result($query_result);
			return $query_data;
		}
		public static function select_sql_multiline($sql_query, $do_htmlspecialchars = false) {
			$query_result = _base::get_query_result($sql_query);
			$data = array();
			while ($query_data = _base::sql_fetch_assoc($query_result, $do_htmlspecialchars)) {
				$data[] = $query_data;
			}
			_base::sql_free_result($query_result);
			return $data;
		}



		public static function get_query_result($sql_query) {
			// Ако няма стартирана self::$WriteTr и self::$ReadTr, стартирам self::$ReadTr
			if (!self::$WriteTr and !self::$ReadTr)
				_base::startReadTr();

			if (!DB_FIREBIRD)
				$query_result = mysqli_query(self::$mysqli, $sql_query);
			else {
				// Ако е стартирана WriteTr се изпълнява в нея, иначе в ReadTr
				$in_tr = (self::$WriteTr) ? self::$WriteTr : self::$ReadTr;
				if (!$in_tr)
					_base::show_sql_error('Can not start transaction !');
				// Подтискам показването на Warning
				$query_result = @ibase_query($in_tr, $sql_query);
			}
			if (!$query_result) {
				_base::show_sql_error($sql_query);
				return false;
			}
			return $query_result;
		}

		public static function sql_fetch_assoc($query_result, $do_htmlspecialchars = false) {
			if (!DB_FIREBIRD) {
				$row = mysqli_fetch_assoc($query_result);
			}
			else 
			{
				try {
					$_row = ibase_fetch_assoc($query_result, IBASE_FETCH_BLOBS);
				} catch(Exception $e) {
					_base::show_sql_error($e);
				}
				if ($_row) {
					foreach($_row as $key => $value)
						$row[strtolower($key)] = $value;
				} else
					$row = false;
			}

			if ($row and $do_htmlspecialchars)
				foreach($row as $key => &$value) {
					$row[$key] = htmlspecialchars($value);
				}
			return $row;
		}

		public static function sql_fetch_row($query_result, $do_htmlspecialchars = false) {
			if (!DB_FIREBIRD)
				$row = mysqli_fetch_row($query_result);
			else
				$row = ibase_fetch_row($query_result, IBASE_FETCH_BLOBS);

			if ($row and $do_htmlspecialchars)
				foreach($row as $key => &$value) {
					$row[$key] = htmlspecialchars($value);
				}
			return $row;
		}

		public static function sql_free_result($query_result) {
			if (!DB_FIREBIRD)
				;
			else
				ibase_free_result($query_result);
		}

		public static function sql_add_field_width($query_result, &$data) {
			// Извличане на ширините на текстовите полета
			if (!DB_FIREBIRD) {
				mysqli_field_seek($query_result, 0);
				while ($finfo = mysqli_fetch_field ($query_result)) {
//print nl2br2 (print_r($finfo, true) . PHP_EOL);
					if ($finfo->type == 253)
						$data['field_width'][$finfo->name] = $finfo->length / 3;
				}
			} else {
				$coln = ibase_num_fields($query_result);
				for ($i = 0; $i < $coln; $i++) {
					$col_info = ibase_field_info($query_result, $i);
					if ($col_info['type'] == 'VARCHAR') {
//print nl2br2 (print_r($col_info, true) . PHP_EOL);
						$data['field_width'][strtolower($col_info['alias'])] = $col_info['length'] / 4;
					}
				}
			}
		}


		public static function insert_id($generator_name = null, $inc_by = 0) {
		//If a generator hasn't been used before it will return 0
			if (!DB_FIREBIRD)
				return mysqli_insert_id(self::$mysqli);
			else {
				// Ако е стартирана WriteTr се изпълнява в нея, иначе в ReadTr
				$in_tr = (self::$WriteTr) ? self::$WriteTr : self::$ReadTr;
				return ibase_gen_id($generator_name, $inc_by, $in_tr);
			}
		}

		public static function sql_get_empty_assoc($query_result) {
			if (!DB_FIREBIRD) {
				mysqli_field_seek($query_result, 0);
				while ($finfo = mysqli_fetch_field($query_result))
					$row[$finfo->name] = null;
			} else {
				$coln = ibase_num_fields($query_result);
				for ($i = 0; $i < $coln; $i++) {
					$col_info = ibase_field_info($query_result, $i);
					$row[strtolower($col_info['alias'])] = null;
				}
			}
			return $row;
		}

		public static function get_fields_name($query_result) {
			if (!DB_FIREBIRD) {
				mysqli_field_seek($query_result, 0);
				while ($finfo = mysqli_fetch_field ($query_result))
					$row[] = $finfo->name;
			} else {
				$coln = ibase_num_fields($query_result);
				for ($i = 0; $i < $coln; $i++) {
					$col_info = ibase_field_info($query_result, $i);
					$row[] = strtolower($col_info['alias']);
				}
			}
			return $row;
		}

		public static function is_view_exists($table) {
		//If a generator hasn't been used before it will return 0
			if (!DB_FIREBIRD) {
				$query_result = _base::get_query_result("SHOW TABLES LIKE 'view_{$table}'");
				$is_view = mysqli_num_rows($query_result) > 0;
			} else {
				$query_result = _base::get_query_result('select 1 from rdb$relations where rdb$relation_name = ' . strtoupper("'view_{$table}'"));
				if (!_base::sql_fetch_row($query_result))
					$is_view = false;
				else
					$is_view = true;
				_base::sql_free_result($query_result);
			}
			return $is_view;
		}


		// Нов начин за запомняне на параметрите по справките, като се групират отделно за всяка справка
		public static function readFilterToSESSION_new($prefix = null){
			// Ако няма посочен префикс (група), то се записват в обща група "params"
			if (!$prefix) $prefix = 'params';
			foreach ($_POST as $id => $item)
				$_SESSION[$prefix][$id] = $item;
		}

		// Разделя $_REQUEST[$p] == 'param_name=param_value' на две променливи
		public static function parseREQUEST_p($p, &$param_name, &$param_value) {
			// Връща false, ако няма подаден $_REQUEST[$p] или в него няма =
			if (isset($_REQUEST[$p])) {
				$pos = strpos($_REQUEST[$p], '=');
				if ($pos) {
					$param_name = substr($_REQUEST[$p], 0, $pos);
					$param_value = substr($_REQUEST[$p], $pos+1);
//echo $param_name . ' ' . $param_value;
					return true;
				}
			}
			unset($param_name);
			unset($param_value);
			return false;
		}


// uploads
		public static function display_file($targetFile, $thumb = false, $small_thumb = false) {
			$ext = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));
				
			// Ако се иска малък thumb - за Анекси, Споразучение за напускане
			if ($small_thumb) {
				// Да намерим подходящата иконка за разширението
				$targetFile = UPLOADS_DIR . '/file-icons/32px/'.$ext.'.png';
				if (!file_exists($targetFile))
					$targetFile = UPLOADS_DIR . '/file-icons/32px/'.'_blank.png';
			} else {
				// Ако се иска нормален thumb
				if ($thumb)
					$targetFile = pathinfo($targetFile,  PATHINFO_DIRNAME) . '/' . THUMB_PREFIX . pathinfo($targetFile,   PATHINFO_BASENAME);

				if (!file_exists($targetFile) && $thumb) {
					// Да намерим подходящата иконка за разширението
					$targetFile = UPLOADS_DIR . '/file-icons/48px/'.$ext.'.png';
					if (!file_exists($targetFile))
						$targetFile = UPLOADS_DIR . '/file-icons/48px/'.'_blank.png';
				}
			}
			
			if ($thumb) {
				readfile($targetFile);
				return;
			}

			if (file_exists($targetFile)) {
				/*
				// Това е header за download
				header("Content-Type: application/octet-stream");
				header("Content-Length: " . filesize($targetFile));
				header('Content-Disposition: attachment; filename="'.basename($targetFile).'"');
				*/

				// Така направо се показва в прозореца
				header("Content-Type: application/octet-stream");
				readfile($targetFile);
			} else {
				echo $targetFile;
			}
		}


		public static function send_user_mail($data_mail, $silent = false) {
			if ($data_mail['user_email']) {
				$mail = new MyMailer;
				//$mail->AddAddress($data_mail['user_email'], $data_mail['user_full_name']);
				$mail->AddAddress($data_mail['user_email']);
				$mail->Subject = "Метро платформа Лагермакс";
				$mail->Body = 
					"Това е автоматично съобщение, което Ви предоставя достъп до WEB портала за Заявки на Метро платформа Лагермакс"
					. PHP_EOL
					. PHP_EOL . "http://$_SERVER[HTTP_HOST]". ($data_mail['org_id'] ? "/".$data_mail['org_id'] : "")
					. PHP_EOL
					. PHP_EOL . "Доставчик име: ".$data_mail['org_name']
					. PHP_EOL . "Доставчик номер: ".$data_mail['org_id']
					. PHP_EOL . "Име: ".$data_mail['user_name']
					. PHP_EOL . "Парола: ".$data_mail['user_password'];
				//set_time_limit(10);
				if(!$mail->Send()) {
					if (!$silent)
						echo 'Mailer Error: ' . $mail->ErrorInfo;
					return false;
				}
				// extension=php_imap.dll
				//$mail->copyToFolder("Users");
				unset($mail);
				return true;
			}
			return false;
		}

		public static function finish_db_connection() {
			/*
			if (self::$WriteTr)
				_base::log_in_file('finish WriteTr', false);
			if (self::$transaction_count > 0)
				_base::log_in_file('finish transaction_count ' . self::$transaction_count, false);
			_base::rollback_transaction();
			_base::commitReadTr();
			_base::log_in_file('==============', false);
			*/
		}
		public static function log_in_file($message, $inclide_trace = true) {
			$prefix = '=========================================' . PHP_EOL;
			// [2017-05-03 09:52:07] IP user_id org_name
			$prefix .=  '['.date("Y-m-d H:i:s").'] ' . $_SERVER['REMOTE_ADDR'] . ' user_id:' . $_SESSION['userdata']['user_id'] . $_SESSION['userdata']['org_name'] . PHP_EOL;
			file_put_contents(FILE_NAME_ERROR, $prefix . $message . PHP_EOL, FILE_APPEND);
			if ($inclide_trace)
				file_put_contents(FILE_NAME_ERROR, _base::get_trace(1), FILE_APPEND);
		}
	} // class _base

	class ExecQuery {
		// assoc array, откъдето да се взимат стойностите
		public $a_get_values;
		// assoc array [param_name => param_value, ]
		public $a_params = array();
		// Името на таблицата
		public $table;
		// Името на генератора. По подразбиране е $this->table."_id"
		public $generator_name;
		// Името на PK. По подразбиране е $this->table."_id"
		public $pk_name;

		// Дали да добавя cr_user_id, mo_user_id, cr_date, mo_date
		public $add_cr_mo = true;
		public $skip_add_mo = false;

		// При създаване, тука остава записано стойността на $curr_time
		public $curr_time;

		// Ако $a_get_values е масив, то това е масива за стойностите
		// Ако $a_get_values е true, то масива за стойностите е $_POST
		public function __construct ($table, $a_get_values = true) {
			if (is_array($a_get_values))
				$this->a_get_values = $a_get_values;
			else
			if ($a_get_values)
				$this->a_get_values = $_POST;
			$this->table = $table;
			$this->generator_name = $this->table."_id";
			$this->pk_name = $this->table."_id";

			$this->curr_time = gmdate("Y-m-d H:i:s");
		}

		public function AddParamExt($param_name, $param_value, $type = 's', $default_value = null) {
			// $type = n-umeric, s-tring, d-ate, c-har(1)
			// Ако е d-ate, то тя е подадена във формат 25.01.2015
			// Ако липсва параметъра в $_POST, то нищо не добавяме
			
			if (!DB_FIREBIRD)
				$param_name = '`'.$param_name.'`';
			else
				$param_name = '"'.strtoupper($param_name).'"';

			// Ако вече има такъв параметър, да не се добавя втори път
			if (array_key_exists($param_name, $this->a_params)) return;

			$s = $param_value;
			if (isset($default_value) and (!$s))
				$s = $default_value;

			if ($type == 'd') {
				_base::StrToMySqlDate($s);
			}
			
			if ($type == 'c') {
				if (!$s)
					$this->a_params[$param_name] = "'0'";
				else
					$this->a_params[$param_name] = "'" . _base::escape_string($s) . "'";
			}
			else 
			if ($s === "" || is_null($s) )
				$this->a_params[$param_name] = "NULL";
			else
			if ($type == 'n') {
				$s = 0 + $s;
				$this->a_params[$param_name] = $s;
			}
			else 
			if ($type == 'd')
				$this->a_params[$param_name] = "'" . _base::escape_string($s) . "'";
			else
			if ($type == 't')
				$this->a_params[$param_name] = "'" . _base::escape_string($s) . "'";
			else
			{
				// Интерпретира се като стринг
				// 30.05.2016 - Декодиране на специалните символи
				$s = htmlspecialchars_decode($s);
				$this->a_params[$param_name] = "'" . _base::escape_string(rtrim($s)) . "'";
			}
		}
		public function AddParam($param_name, $type = 's', $default_value = null) {
			// $type = n-umeric, s-tring, d-ate, b-lob, c-har(1)
			// Ако е d-ate, то тя е подадена във формат 25.01.2015
			// Ако липсва параметъра в $_POST, то нищо не добавяме
			// -няма да е горното, защото CheckBoxes, които не са чекнати не се подава параметър в $_POST, а трябва да се записва '0'
			if (!array_key_exists($param_name, $this->a_get_values) and $type != 'c') return;
			$this->AddParamExt($param_name, $this->a_get_values[$param_name], $type, $default_value);
		}

		public function insert() {
			// Създава (field1, ...) values (value1, ...)

			_base::start_transaction();
			if ($this->add_cr_mo) {
				if (!$this->skip_add_mo) {
					$this->AddParamExt('mo_user_id', $_SESSION['userdata']['user_id'], 'n', 0);
					$this->AddParamExt('mo_date', $this->curr_time, 'd', null);
				}
				$this->AddParamExt('cr_user_id', $_SESSION['userdata']['user_id'], 'n', 0);
				$this->AddParamExt('cr_date', $this->curr_time, 'd', null);
			}
			// Да вземем следващата стойност на генератора и да я добавим като параметър
			if (DB_FIREBIRD and $this->generator_name) {
				// Ако е стартирана WriteTr се изпълнява в нея, иначе в ReadTr
				$in_tr = (_base::$WriteTr) ? _base::$WriteTr : _base::$ReadTr;
				$new_id = ibase_gen_id($this->generator_name, 1, $in_tr);
				$this->AddParamExt($this->pk_name, $new_id, 'n');
			}

			$result = "(";
			$values = "values(";
			$comma = '';
			foreach($this->a_params as $field_name => $field_value) {
				$result .= $comma . $field_name;
				$values .= $comma . $field_value;
				// След първото добавено поле, почваме да слагаме запетайка отпред
				if(!$comma) $comma = ", ";
			}
			$result = "INSERT INTO " . $this->table . PHP_EOL . $result . ") " . PHP_EOL . $values . ")";

			_base::execute_sql($result);

			if (!DB_FIREBIRD and $this->generator_name)
				$new_id = _base::insert_id($this->generator_name);

			_base::commit_transaction();
			return $new_id;
		}

		public function update($a_pk) {
			// Създава  SET field1 = value1, ... WHERE (pk1 = value_pk1) and ...

			_base::start_transaction();
			if ($this->add_cr_mo) {
				$this->AddParamExt('mo_user_id', $_SESSION['userdata']['user_id'], 'n', 0);
				$this->AddParamExt('mo_date', $this->curr_time, 'd', null);
			}

			$result = "SET ";
			$comma = '';
			foreach($this->a_params as $field_name => $field_value) {
				$result .= $comma . $field_name . " = " . $field_value;
				// След първото добавено поле, почваме да слагаме запетайка отпред
				if(!$comma) $comma = ", ";
			}

			$where = " WHERE ";
			$comma = '';
			foreach($a_pk as $field_name => $field_value) {
				$where .= $comma . "(" . $field_name . " = " . $field_value . ")";
				// След първото добавено поле, почваме да слагаме and отпред
				if(!$comma) $comma = " and ";
			}
			$result = "UPDATE " . $this->table . PHP_EOL . $result . PHP_EOL . $where;
			_base::execute_sql($result);

			_base::commit_transaction();
		}
	}
?>
