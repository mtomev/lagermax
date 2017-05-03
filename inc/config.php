<?php

	require ('database.php');

	$compile_check = true;

	define ('SID', session_id ());

	define ('INC_DIR', dirname (__FILE__));

	// Директория, в която се записват прикачените документи
	define ('UPLOADS_DIR', INC_DIR . '/../uploads');
	// Директория, в която са използваните външни компоненти на PHP
	if (!defined('COMPS_DIR'))
		define ('COMPS_DIR', INC_DIR . '/../comps');

	// Директория, в която са tpl файловете
	define ('TEMPLATES_DIR', INC_DIR . '/templates/');


	define ('THUMB_PREFIX', 'thumb_');
	// Максимални размери на Thumbnail
	define ('THUMB_IMG_WIDTH', 100);
	define ('THUMB_IMG_HEIGHT', 65);

	define ('FILE_NAME_ERROR', rtrim($_SERVER['DOCUMENT_ROOT'], '/ ') . '/error.log');
?>
