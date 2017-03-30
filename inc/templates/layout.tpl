<!DOCTYPE html>
<html>
<head>
	<title>{#site_title#}</title>

	<meta http-equiv="content-type" content="application/xhtml+xml; charset=UTF-8" />
	<meta name="description" content="Metro platform" />
	<meta name="robots" content="index, follow, noarchive" />
	<meta name="googlebot" content="noarchive" />
	<meta name="viewport" content="width=device-width, initial-scale=1">

{if $smarty.session.loggedin}
	<link rel="stylesheet" type="text/css" href="/js/Magnific-Popup/magnific-popup.css" media="screen" />
	<link rel="stylesheet" type="text/css" href="/js/jquery-ui-1.11.4.custom/jquery-ui.min.css" />
	<link rel="stylesheet" type="text/css" href="/js/DataTables/datatables.min.css"/>
	<link rel="stylesheet" type="text/css" href="/js/chosen/chosen.min.css" />
	{* Винаги трябва да е последно *}
	<link rel="stylesheet" type="text/css" href="/css/layout.css" media="screen" />

	<script src="/js/jquery-1.11.3.min.js"></script>
	<script src="/js/Magnific-Popup/jquery.magnific-popup.min.js"></script>
	<script src="/js/jquery-ui-1.11.4.custom/jquery-ui.min.js"></script>
	{if $smarty.session.lang.lang == 'BG'}
	<script src="/js/jquery-ui-1.11.4.custom/datepicker-bg.js"></script>
	{else}
	<script src="/js/jquery-ui-1.11.4.custom/datepicker-en-GB.js"></script>
	{/if}
	<script src="/js/DataTables/datatables.min.js"></script>
	<script src="/js/chosen/chosen.jquery.min.js"></script>
{else}
	<link rel="stylesheet" type="text/css" href="/css/layout.css" media="screen" />
	<script src="/js/jquery-1.11.3.min.js"></script>
{/if}

	<!-- favicon -->
	<link rel="Shortcut Icon" type="image/ico" href="/images/favicon.png?v=2" />
	
<script type="text/javascript">
{if $smarty.session.loggedin}
	{include file='EsCon.js'}
	{include file='layout.js'}
{/if}
</script>

</head>

<body style="margin-left: 200px;">

{if $smarty.session.loggedin}
	<div id="content-wrap" class="clear" style="margin-left: -200px;">
		<div id="sidebar">
			{include file="main_menu/sidebar.tpl"}
		</div>
		{block name=content}{/block}
	</div>
{else}
	{include file='main_menu/sidebar_login.tpl'}
{/if}

	<div id="loadingScreen-overlay" style="z-index: 9019; display: none; background: #aaa; opacity: .3; position: fixed; top: 0; left: 0; width: 100%; height: 100%;" {*class="ui-widget-overlay ui-front"*}></div>
	<div id="loadingScreen" style="overflow: hidden; display: none; z-index: 9020 !important; position: fixed; top: 0; left: 0; width: 100%; height: 100%;">
		<div style="display: table; position: absolute; top: 0; left: 0; width: 100%; height: 100%; margin: 0;">
			<div style="display: table-cell; vertical-align: middle; text-align: center; margin: 0;">
				<div style="height: 100px; line-height: 100px; display: inline-block; white-space: nowrap; background-color: white; vertical-align: middle; margin-right: auto; margin-left: auto; padding-left: 10px; padding-right: 10px;">
					<img src="/images/ajax-loader.gif" style="vertical-align: middle;" />
					<span id="message" style="vertical-align: middle; padding-left: 20px; white-space: nowrap;"></span>
				</div>
			</div>
		</div>
	</div>

</body>
</html>
