{extends file="layout.tpl"}
{block name=content}
{*
<div id="main">
	
	<div class="headerrow">
		<span class="header">{#menu_configuration#}</span>
	</div>
	
	<div class="submenu">
		<ul>
			{if $smarty.session.userdata.grants.org == '1'}
			<li><a href="/configuration/org">{#table_org#}</a></li>
			{/if}
			{if $smarty.session.userdata.grants.r_service == '1'}
			<li><a href="/configuration/r_service">{#table_r_service#}</a></li>
			{/if}
			{if $smarty.session.userdata.grants.r_service_group == '1'}
			<li><a href="/configuration/r_service_group">{#table_r_service_group#}</a></li>
			{/if}
			{if $smarty.session.userdata.grants.uom == '1'}
			<li><a href="/configuration/uom">{#table_uom#}</a></li>
			{/if}
			{if $smarty.session.userdata.grants.r_service_firm == '1'}
			<li><a href="/configuration/r_service_firm">{#table_r_service_firm#}</a></li>
			{/if}
			<li>&nbsp;</li>

			{if $smarty.session.userdata.grants.room == '1'}
			<li><a href="/configuration/room">{#table_room#}</a></li>
			{/if}
			{if $smarty.session.userdata.grants.doc_kind == '1'}
			<li><a href="/configuration/doc_kind">{#table_doc_kind#}</a></li>
			{/if}
			{if $smarty.session.userdata.grants.company == '1'}
			<li><a href="/configuration/company">{#table_company#}</a></li>
			{/if}
			{if $smarty.session.userdata.grants.charge == '1'}
			<li><a sub_menu="charge" href="/configuration/charge">{#table_charge#}</a></li>
			{/if}
			{if $smarty.session.userdata.grants.vat == '1'}
			<li><a sub_menu="vat" href="/configuration/vat">{#table_vat#}</a></li>
			{/if}
			<li>&nbsp;</li>

			{if $smarty.session.userdata.grants.personal == '1'}
			<li><a href="/configuration/personal">{#table_personal#}</a></li>
			{/if}
			{if $smarty.session.userdata.grants.user == '1'}
			<li><a href="/configuration/user">{#table_user#}</a></li>
			{/if}

			{if $smarty.session.userdata.grants.user == '1'}
			<li><a href="/configuration/user_role">{#table_user_role#}</a></li>
			{/if}
			<li>&nbsp;</li>

			{if $smarty.session.userdata.grants.config == '1'}
			<li><a href="/configuration/config">{#table_config#}</a></li>
			<li>&nbsp;</li>
			{/if}

			{if $smarty.session.userdata.grants.sttlp == '1'}
			<li><a href="/configuration/sttlp">{#menu_sttlp#}</a></li>
			<li>&nbsp;</li>
			{/if}

			{if $smarty.session.userdata.grants.languages == '1'}
			<li><a href="/main_menu/languages">{#languages#}</a></li>
			{/if}
		</ul>
	</div>
	
</div>
*}
{/block}