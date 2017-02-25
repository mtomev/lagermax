<?php
	//require_once(INC_DIR . '/class_classes.php');
	foreach (glob (INC_DIR . '/class_*.php') as $filename) {
		require_once ($filename);
	}

	function exceptions_error_handler($severity, $message, $filename, $lineno) {
		if (error_reporting() == 0) {
			return;
		}
		if (error_reporting() & $severity) {
			_base::show_sql_error('Error global'. PHP_EOL . $message);
		}
	}

	class site {
		public $smarty;
		var $base = '.';
		var $method = 'deflt';
	
		function __construct () {
			global $compile_check;
			global $mysqli_conn;
			global $mysql_host, $mysql_user, $mysql_pass, $mysql_db;
			global $dbMain;

			if (!defined('DB_FIREBIRD'))
				define ('DB_FIREBIRD', false);
			if (!DB_FIREBIRD) {
				// MySQL
				$mysqli_conn = mysqli_connect($mysql_host, $mysql_user, $mysql_pass, $mysql_db);
				if (mysqli_connect_errno()) die ("Cannot connect to MySQL server!");

				if (mysqli_connect_errno()) {
					echo "Failed to connect to MySQL: " . mysqli_connect_error();
				}
				$this->mysqli = $mysqli_conn;
				_base::$mysqli = $this->mysqli;
				mysqli_set_charset($this->mysqli, 'utf8');
			}
			else
			{
				// Firebird
				if (defined('USE_CONNECT') and USE_CONNECT)
					$dbMain = ibase_connect($mysql_host, $mysql_user, $mysql_pass, 'UTF8');
				else
					$dbMain = ibase_pconnect($mysql_host, $mysql_user, $mysql_pass, 'UTF8');
				_base::$dbMain = $dbMain;
			}

			// create smarty
			$this->smarty = new Smarty;
			_base::$smarty = $this->smarty;
			
			$this->smarty->setTemplateDir(TEMPLATES_DIR);
			$this->smarty->setCompileDir(INC_DIR . '/../cache/templates_c/');
			$this->smarty->setConfigDir(INC_DIR . '/../configs/');
			$this->smarty->setCacheDir(INC_DIR . '/../cache/');
			$this->smarty->compile_check = $compile_check;
			// Има BUG в подразбиращата се стойност за debug_tpl
      $this->smarty->debug_tpl = /*'file:' .*/ SMARTY_DIR . 'debug.tpl';
			
//$smarty->caching = true;

			$this->global_variables ();

// debugging трябва да е след global_variables
//$this->smarty->debugging = true;

			set_error_handler('exceptions_error_handler', E_WARNING);

			// $_REQUEST{'a'}/$_REQUEST{'b'}/$_REQUEST{'p1'}/$_REQUEST{'p2'}/$_REQUEST{'p3'}/$_REQUEST{'p4'}
			// class/method/p1/p2/p3/p4
			// Само при Home няма подаден $_REQUEST{'a'}
			// Ако има първи параметър - номера на Доставчик org_id
			$org_id = intVal($_REQUEST['a']);
			if (!isset($_REQUEST['a']) or $org_id) {
				$_REQUEST['a'] = 'main_menu';
				$_REQUEST['b'] = 'deflt';
				$_SESSION['org_id'] = $org_id;
			}
			if (!$_REQUEST{'b'}) $_REQUEST{'b'} = 'deflt';
			$_REQUEST{'b'} ? $method = $_REQUEST{'b'} : $method = $_REQUEST{'a'};

			$_REQUEST{'b'} ? $method_class = $_REQUEST{'a'} : $method_class = 'main_menu';
		
			if (class_exists ($method_class)) {
				if (!method_exists ($method_class, $method)) {
					unset ($_REQUEST['b']);
					$method = 'deflt';
				}
				$this->method = $method;
				$_REQUEST['b'] ? $this->base = $_REQUEST['a'] : $this->base = 'main_menu';
				$action = new $method_class ($this->smarty);		    
				$action->$method ();
			}
		}

		function __destruct () {
			_base::rollback_transaction();
			_base::commitReadTr();
		}

		public function display () {
			// display page
			// Ако съм задал от процедурата новия tpl
			$path = isset($_SESSION['display_path'])?$_SESSION['display_path']:null;
			if (!$path)
				$path = $this->base . '/' . $this->method . '.tpl';

			// Отрязвам първата /
			if (substr($path, 0, 1) == '/') $path = substr($path, 1);

			unset ($_SESSION['display_path']);

			// Правя го така, за да се показват грешките
			// Иначе, при липсващ tpl (напр. при запис) винаги минава първо през main_menu/deflt.tpl
			if (file_exists (TEMPLATES_DIR . $path))
				$this->smarty->display($path); 
		}

		function global_variables () {
			if (!$_SESSION['lang']['lang']) $_SESSION['lang']['lang'] = 'BG';

			// Find all language files
			$fname = sprintf ("%slang_*.txt", $this->smarty->config_dir[0]);
			$fpatt = "/lang\_(.*)\.txt/";
			$lang_exists = false;
			unset($_SESSION['langs']);
			foreach (glob ($fname) as $file) {
				preg_match ($fpatt, $file, $fmatch);
				$_SESSION['langs'][/*$fmatch[1]*/] = $fmatch[1];
				if (!$lang_exists and $_SESSION['lang']['lang'] == $fmatch[1])
					$lang_exists = true;
			}
			if (!$lang_exists) 
				$_SESSION['lang']['lang'] == $_SESSION['langs'][0];
			
			// Зареждането на Lang Pack трябва да е внимателно, защото може да е прецакано
			// Добре е в директорията да има един винаги един добър файл, който не се редактира от потребителя
			// например _DEF.txt
			try {
				$this->smarty->ConfigLoad('lang_' . $_SESSION['lang']['lang'] . '.txt');
			} catch(Exception $e) {
				$this->smarty->ConfigLoad('_DEF.txt');
				//echo (nl2br("\n<b>Error loading ".'lang_' . $_SESSION['lang']['lang'] . '.txt'."</b>\n\n"));
				//echo (nl2br("\n<b>Error loading ".'lang_' . $_SESSION['lang']['lang'] . '.txt'."</b>\n\n".$e));
			}
/*
//echo (nl2br(print_r($this->smarty->getConfigVars(), true)));
$fname = $this->smarty->config_dir[0] . "lang_" . $_SESSION['lang']['lang'] . ".txt";
// INI_SCANNER_NORMAL,  INI_SCANNER_RAW
$ini_array = parse_ini_file($fname, true,  INI_SCANNER_RAW);
echo (nl2br(print_r($ini_array, true)));
*/
			// След като сме определили $_SESSION['lang']['lang'], да зададем и другите параметри за lang
			/*
			lang: {
				langId: "de-DE",
				thousands: ".",
				decimal: ",",
				currencySymbol: "€",
				dateSep: ".",
			},
			*/
			$_SESSION['lang']['langId'] = $this->smarty->getConfigVars('lang_langId');
			$_SESSION['lang']['thousands'] = $this->smarty->getConfigVars('lang_thousands');
			$_SESSION['lang']['decimal'] = $this->smarty->getConfigVars('lang_decimal');
			$_SESSION['lang']['currencySymbol'] = $this->smarty->getConfigVars('lang_currencySymbol');
			$_SESSION['lang']['dateSep'] = $this->smarty->getConfigVars('lang_dateSep');
		}
	
	}


?>
