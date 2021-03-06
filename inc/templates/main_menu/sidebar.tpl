	{if $smarty.session.loggedin}
	<a href="/" style="cursor: pointer;" title="">
		<img style="padding-left:5px; padding-right:5px; width:200px; margin-top: 5px; height:auto;" src="/images/lagermax_logo.png" alt="" border="0">
	</a>
	<div id="sidemenu">
		<ul class="sidemenu">

			<li>
			{if $smarty.session.userdata.grants.aviso == '1'}
			<a main_menu="aviso" href="/aviso/aviso">{#menu_aviso#}</a>
			{else}
			<a main_menu="aviso" href="#">{#menu_aviso#}</a>
			{/if}
			<ul main_menu="aviso" class="submenu">
				{if $smarty.session.userdata.grants.aviso_detail == '1'}
				<li><a sub_menu="aviso_detail" href="/aviso/aviso_detail">{#menu_aviso_detail#}</a></li>
				{/if}
			</ul>
			</li>

			<li>
			<a main_menu="plt" href="/" class="expand">{#menu_plt#} ></a>
			<ul main_menu="plt" class="submenu">
				{if $smarty.session.userdata.grants.pltorg == '1'}
				<li><a sub_menu="pltorg" href="/plt/pltorg">{#menu_pltorg#}</a></li>
				{/if}
				{if $smarty.session.userdata.grants.pltshop == '1'}
				<li><a sub_menu="pltshop" href="/plt/pltshop">{#menu_pltshop#}</a></li>
				{/if}
			</ul>
			</li>

			<li>
			<a main_menu="reports" href="/" class="expand">{#menu_reports#} ></a>
			<ul main_menu="reports" class="submenu">
				{if $smarty.session.userdata.grants.rep_timeslot == '1'}
				<li><a sub_menu="rep_timeslot" href="/reports/rep_timeslot">{#menu_rep_timeslot#}</a></li>
				{/if}
				{if $smarty.session.userdata.grants.rep_timeslot_shop == '1'}
				<li><a sub_menu="rep_timeslot_shop" href="/reports/rep_timeslot_shop">{#menu_rep_timeslot_shop#}</a></li>
				{/if}
				{if $smarty.session.userdata.grants.rep_plt_balans == '1'}
				<li><a sub_menu="rep_plt_balans" href="/reports/rep_plt_balans">{#menu_rep_plt_balans#}</a></li>
				{/if}
				{if $smarty.session.userdata.grants.rep_pltshop_balans == '1'}
				<li><a sub_menu="rep_pltshop_balans" href="/reports/rep_pltshop_balans">{#menu_rep_pltshop_balans#}</a></li>
				{/if}
			</ul>
			</li>

			<li>
			<a main_menu="configuration" href="/" class="expand">{#menu_configuration#} ></a>
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

			<li>
			<a main_menu="sys_reports" href="/" class="expand">{#menu_sys_reports#} ></a>
			<ul main_menu="sys_reports" class="submenu">
				{if $smarty.session.userdata.user_id == '1'}
				<li><a sub_menu="sys_session" href="/sys_reports/sys_session">SESSION</a></li>
				{/if}
				{if $smarty.session.userdata.grants.sys_oper == '1'}
				<li><a sub_menu="sys_oper" href="/sys_reports/sys_oper">{#table_sys_oper#}</a></li>
				{/if}
				{if $smarty.session.userdata.grants.sys_logon == '1'}
				<li><a sub_menu="sys_logon" href="/sys_reports/sys_logon">{#table_sys_logon#}</a></li>
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
		<button id="temp_button" class="submit_button"><span>pltorg</span></button>
		{/if*}
	</div>

	<div style="padding-left:10px;padding-right:10px;">
		{if $smarty.session.userdata.grants.aviso_reception == '1'}
		<br>
		<button id="aviso_edit_receipt_button" class="green_button" href="/aviso/aviso_edit_receipt"><span>{#menu_aviso_reception#}</span></button>
		<br>
		<br>
		<button id="aviso_select_for_complete_button" class="green_button" href="/aviso/aviso_select_for_complete"><span>{#aviso_complete#}</span></button>
		{/if}
	</div>
	{/if}

<script type="text/javascript">
	//Да се виждат всички
	// Скривам всички подменютата, на главните менюта от клас expand
	$("ul.submenu", "#sidemenu li:has(a.expand)").addClass("hidden");
	// Разпъвам текущото подменю
	$("ul[main_menu='{$smarty.session.main_menu}'].submenu", "#sidemenu").removeClass("hidden");
	
	// Скривам всички главни менюта, които подменю
	$("li:has(a.expand):not(:has(li))", "#sidemenu").addClass("hidden");

	// На всички главни менюта от клас expand
	$("li a.expand", "#sidemenu").on('click', function () {
		var $ul = $(this).parent().children('ul');
		if ($ul.hasClass("hidden"))
			$ul.removeClass("hidden");
		else
			$ul.addClass("hidden");
		return false;
	});

	$(document).ready( function () {
		var $sub_menu = $("ul[main_menu='{$smarty.session.main_menu|default:''}'] a[sub_menu='{$smarty.session.sub_menu|default:''}']", '#sidemenu');
		if ($sub_menu.length) {
			$sub_menu.addClass("selected");
			current_menu_text = $sub_menu.html();
		} else {
			var $main_menu = $("li a[main_menu='{$smarty.session.main_menu}']", '#sidemenu');
			$main_menu.addClass("selected");
			current_menu_text = $main_menu.html();
		}
	}); // $(document).ready

	$('#logout_button').click(function () {
		jQuery.post('/main_menu/logout', {}, function (result) {
			if (result)
				$("#main").prepend( result );
			else
				window.location.href = '/';
		});
	});

	{*
	$('#temp_button').click(function () {
		waitingDialog('pltorg -> ...');
		jQuery.post('/configuration/temp_update', {}, function (result) {
			closeWaitingDialog();
			if (result)
				fnShowErrorMessage('', result);
			else
				window.location.href = '/';
		});
	});
	*}

	{if $smarty.session.userdata.grants.aviso_reception == '1'}
	$('#sidemenu #aviso_edit_receipt, #sidemenu #aviso_select_for_complete, #aviso_edit_receipt_button, #aviso_select_for_complete_button').on('click', function(event) {
		event.preventDefault();
		event.stopImmediatePropagation();
		is_edit_child = false;

		$this = $(this);

		var url = $this.attr("url");
		if (!url)
			url = $this.attr("href");
		var a_rel = $this.attr("rel");

		// Дали е нов елемент, който после се добавя в таблицата
		edit_row = null;
		edit_id = 0;
		edit_delete = false;
		edit_add_new = false;
		if (url === '') return;
		showMFP(url, { }, '#aviso_id');
	});
	{/if}
</script>
