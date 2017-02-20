<?php
	header ('Content-Type: text/html; charset=utf-8');

	ini_set('session.name', 'LagermaxSesID');

	if (!ob_start ('ob_gzhandler'))
		ob_start();
	if (isset ($_POST{'LagermaxSesID'}))
		session_id($_POST{'LagermaxSesID'});
	session_start();

	ini_set('display_errors', 1);
	ini_set('display_startup_errors', 1);
	error_reporting (E_ALL ^ E_NOTICE);

	date_default_timezone_set('Europe/Sofia');
	@setlocale (LC_TIME, 'bg_BG.utf8');
	mb_language('uni');

	require ('../inc/config.php');

	require (COMPS_DIR.'/smarty-3.1.29/libs/Smarty.class.php');
	require (INC_DIR.'/lib_site.php');
	try {
		$site = new site();
		$site->display();
	} catch(Exception $e) {
		var_dump(nl2br($e->getMessage()));
		var_dump(nl2br("\n\n".$e->getTraceAsString()));
	}
	unset($site);
?>
