	{if $smarty.session.loggedin}
	<a href="/" style="cursor: pointer;" title="">
		<img style="padding-left:5px; padding-right:5px; width:200px; margin-top: 5px; height:auto;" src="/images/lagermax_logo.png" alt="" border="0">
	</a>
	<div id="sidemenu">
		<ul class="sidemenu">

			{if $smarty.session.userdata.grants.aviso == '1'}
			<li><a main_menu="aviso" href="/aviso/aviso">{#menu_aviso#}</a>
			{else}
			<li><a main_menu="aviso" href="#">{#menu_aviso#}</a>
			{/if}
			<ul main_menu="aviso" class="submenu">
				{if $smarty.session.userdata.grants.aviso_detail == '1'}
				<li><a sub_menu="aviso_detail" href="/aviso/aviso_detail">{#menu_aviso_detail#}</a></li>
				{/if}
			</ul>
			</li>

			{if $smarty.session.userdata.grants.aviso_reception == '1'}
			<li><a main_menu="aviso_reception" href="/aviso/aviso_reception">{#menu_aviso_reception#}</a>
			{/if}

			{if $smarty.session.userdata.grants.reports == '1'}
			<li><a main_menu="reports" href="/reports/timeslot">{#menu_reports#}</a>
			{/if}

			{if $smarty.session.userdata.grants.configuration == '1'}
			{*<li><a main_menu="configuration" href="/configuration">{#menu_configuration#}</a>*}
			<li><a main_menu="configuration" href="#">{#menu_configuration#}</a>
			{else}
			<li><a main_menu="configuration" href="#">{#menu_configuration#}</a>
			{/if}
			<ul main_menu="configuration" class="submenu">
				{if $smarty.session.userdata.grants.w_group == '1'}
				<li><a sub_menu="w_group" href="/configuration/w_group">{#menu_w_group#}</a></li>
				{/if}
				{if $smarty.session.userdata.grants.warehouse == '1'}
				<li><a sub_menu="warehouse" href="/configuration/warehouse">{#menu_warehouse#}</a></li>
				{/if}
				{if $smarty.session.userdata.grants.org == '1'}
				<li><a sub_menu="org" href="/configuration/org">{#menu_org#}</a></li>
				{/if}
				{if $smarty.session.userdata.grants.shop == '1'}
				<li><a sub_menu="shop" href="/configuration/shop">{#menu_shop#}</a></li>
				{/if}

				{if $smarty.session.userdata.grants.user == '1'}
				<li style="margin-top:10px;"><a sub_menu="user" href="/configuration/user">{#menu_user#}</a></li>
				<li><a sub_menu="user_role" href="/configuration/user_role">{#menu_user_role#}</a></li>
				{/if}

				{if $smarty.session.userdata.grants.config == '1' || $smarty.session.userdata.grants.calendar == '1' || $smarty.session.userdata.grants.languages == '1'}
				<li style="margin-top:10px;"></li>
				{/if}
				{if $smarty.session.userdata.grants.config == '1'}
				<li><a sub_menu="config" href="/main_menu/config_edit">{#menu_config#}</a></li>
				{/if}
				{if $smarty.session.userdata.grants.calendar == '1'}
				<li><a sub_menu="calendar" href="/configuration/calendar">{#menu_calendar#}</a></li>
				{/if}
				{if $smarty.session.userdata.grants.languages == '1'}
				<li><a sub_menu="languages" href="/main_menu/languages">{#menu_languages#}</a></li>
				{/if}
			</ul>
			</li>

			{if $smarty.session.userdata.grants.sys_reports == '1' && $smarty.session.userdata.user_id == '1'}
			<li><a main_menu="sys_reports" href="/sys_reports/deflt">{#menu_sys_reports#}</a>
			{else}
			<li><a main_menu="sys_reports" href="#">{#menu_sys_reports#}</a>
			{/if}
			<ul main_menu="sys_reports" class="submenu">
				{if $smarty.session.userdata.grants.sys_oper == '1'}
				<li><a sub_menu="sys_oper" href="/sys_reports/sys_oper">{#table_sys_oper#}</a></li>
				{/if}
				{if $smarty.session.userdata.grants.sys_logon == '1'}
				<li><a sub_menu="sys_logon" href="/sys_reports/sys_logon">{#table_sys_logon#}</a></li>
				{/if}
				{if $smarty.session.userdata.user_id == '1'}
				<li><a sub_menu="sys_logon1" href="/sys_reports/sys_logon1">{#table_sys_logon#}</a></li>
				{/if}
			</ul>
			</li>

		</ul>
	</div>

	<div style="padding-right: 10px;">
		<div style="margin-left: 10px;">
			<button id="logout_button" class="submit_button"><span>{#btn_logout#}</span></button>
			{if !$dont_include_lang}
			{include file='main_menu/sidebar_lang.tpl'}
			{/if}
		</div>
		<div class="a-href" style="margin-top: 10px; padding: 4px 10px;">
		<a rel="/configuration/user_profil_edit" onclick="showMFP(this.rel)" style="cursor: pointer;" title="{#edit_profil_title#}">{$smarty.session.userdata.user_name}</a>
		</div>
		{*if $smarty.session.userdata.user_id == '1'}
		<br>{$smarty.session.table_edit}
		<button id="temp_button" class="submit_button"><span>gen user passw</span></button>
		{/if*}
	</div>
	{/if}

<script type="text/javascript">
	/* Да се виждат всички
	// Скривам всички подменютата, без онези на които предходния li е забранен за избиране, т.е. href='#'
	$(".submenu", "#sidemenu li:not(:has(a[href='#']))").addClass("hidden");
	// Разпъвам текущото подменю
	$("ul[main_menu='{$smarty.session.main_menu}'].submenu", "#sidemenu").removeClass("hidden");
	*/

	// Скривам всички главни менюта, които са забранени за избиране и нямат подменю
	$("li:has(a[href='#']):not(:has(li))", "#sidemenu").addClass("hidden");

	var main_menu = $("[main_menu='{$smarty.session.main_menu}']", '#sidemenu');
	var sub_menu = $("ul[main_menu='{$smarty.session.main_menu|default:''}'] a[sub_menu='{$smarty.session.sub_menu|default:''}']", '#sidemenu');
	if (sub_menu.length) {
		$(sub_menu).addClass("selected");
		current_menu_text = $(sub_menu).html();
	} else {
		$(main_menu).addClass("selected");
		current_menu_text = $(main_menu).html();
	}

	$('#logout_button').click(function () {
		jQuery.post('/main_menu/logout', {}, function (result) {
			if (result)
				$("#main").prepend( result );
			else
				window.location.href = '/';
		});
	});

	$('#temp_button').click(function () {
		waitingDialog('gen user passw -> ...');
		jQuery.post('/configuration/temp_update', {}, function (result) {
			closeWaitingDialog();
			if (result)
				fnShowErrorMessage('', result);
			else
				window.location.href = '/';
		});
	});

</script>
