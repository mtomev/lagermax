<div id="nomedit" class="white-popup-block">
	<div class="header">
	{if $data.id > 0}{#Edit#}{else}{#Add#}{/if} {#table_user_role#}
	</div>

	<div id="edit" class="nomedit-edit">
		<div class="table-row">
			<div class="table-cell-label">{#name#}</div>
			<div class="table-cell">
				<input id="user_role_name" class="text30 mandatory" type="text" maxlength="{$data.field_width.user_role_name}" name="user_role_name" value="{$data.user_role_name}">
				<span>&nbsp;&nbsp;</span>
				<button class="submit_button" id="checkAllButton"><span>Check all</span></button>
				<span>&nbsp;&nbsp;</span>
				<button class="submit_button" id="uncheckAllButton"><span>Uncheck all</span></button>
			</div>
		</div>

		<hr>

		<div class="" id="gratns_flags">
			<div class="table-row">
				<div class="table-cell-label"><b>{#menu_aviso#}</b></div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="aviso" {if $data.grants["aviso"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="aviso_view" {if $data.grants["aviso_view"] == '1'}checked{/if}> {#view_detail#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="aviso_add" {if $data.grants["aviso_add"] == '1'}checked{/if}> {#add#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="aviso_edit" {if $data.grants["aviso_edit"] == '1'}checked{/if}> {#edit#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="aviso_delete" {if $data.grants["aviso_delete"] == '1'}checked{/if}> {#delete#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>

			<div class="table-row">
				<div class="table-cell-label">{#menu_aviso_detail#}</b></div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="aviso_detail" {if $data.grants["aviso_detail"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
					{*
					<input type="checkbox" value="1" rel="aviso_detail_view" {if $data.grants["aviso_detail_view"] == '1'}checked{/if}> {#view_detail#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="aviso_detail_add" {if $data.grants["aviso_detail_add"] == '1'}checked{/if}> {#add#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="aviso_detail_edit" {if $data.grants["aviso_detail_edit"] == '1'}checked{/if}> {#edit#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="aviso_detail_delete" {if $data.grants["aviso_detail_delete"] == '1'}checked{/if}> {#delete#}
					<span>&nbsp;&nbsp;</span>
					*}
				</div>
			</div>

			<div class="table-row">
				<div class="table-cell-label"><b>{#menu_aviso_reception#}</b></div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="aviso_reception" {if $data.grants["aviso_reception"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="aviso_reception_view" {if $data.grants["aviso_reception_view"] == '1'}checked{/if}> {#view_detail#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="aviso_reception_edit" {if $data.grants["aviso_reception_edit"] == '1'}checked{/if}> {#edit#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="aviso_reception_delete" {if $data.grants["aviso_reception_delete"] == '1'}checked{/if}> {#delete#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>

			<div class="table-row">
				<div class="table-cell-label"><b>{#menu_plt#}</b></div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="plt" {if $data.grants["plt"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>
			<div class="table-row">
				<div class="table-cell-label">{#menu_pltorg#}</b></div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="pltorg" {if $data.grants["pltorg"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="pltorg_view" {if $data.grants["pltorg_view"] == '1'}checked{/if}> {#view_detail#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="pltorg_edit" {if $data.grants["pltorg_edit"] == '1'}checked{/if}> {#edit#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="pltorg_delete" {if $data.grants["pltorg_delete"] == '1'}checked{/if}> {#delete#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>
			<div class="table-row">
				<div class="table-cell-label">{#menu_pltshop#}</b></div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="pltshop" {if $data.grants["pltshop"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="pltshop_view" {if $data.grants["pltshop_view"] == '1'}checked{/if}> {#view_detail#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="pltshop_edit" {if $data.grants["pltshop_edit"] == '1'}checked{/if}> {#edit#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="pltshop_delete" {if $data.grants["pltshop_delete"] == '1'}checked{/if}> {#delete#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>

			<div class="table-row">
				<div class="table-cell-label"><b>{#menu_reports#}</b></div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="reports" {if $data.grants["reports"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>


	{* menu_configuration *}
			<br>
			<div class="table-row">
				<div class="table-cell-label"><b>{#menu_configuration#}</b></div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="configuration" {if $data.grants["configuration"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>

			<div class="table-row">
				<div class="table-cell-label">{#table_w_group#}</div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="w_group" {if $data.grants["w_group"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="w_group_view" {if $data.grants["w_group_view"] == '1'}checked{/if}> {#view_detail#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="w_group_edit" {if $data.grants["w_group_edit"] == '1'}checked{/if}> {#edit#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="w_group_delete" {if $data.grants["w_group_delete"] == '1'}checked{/if}> {#delete#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>


			<div class="table-row">
				<div class="table-cell-label">{#menu_warehouse#}</div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="warehouse" {if $data.grants["warehouse"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="warehouse_view" {if $data.grants["warehouse_view"] == '1'}checked{/if}> {#view_detail#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="warehouse_edit" {if $data.grants["warehouse_edit"] == '1'}checked{/if}> {#edit#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="warehouse_delete" {if $data.grants["warehouse_delete"] == '1'}checked{/if}> {#delete#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>

			<div class="table-row">
				<div class="table-cell-label">{#table_org#}</div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="org" {if $data.grants["org"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="org_view" {if $data.grants["org_view"] == '1'}checked{/if}> {#view_detail#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="org_edit" {if $data.grants["org_edit"] == '1'}checked{/if}> {#edit#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="org_delete" {if $data.grants["org_delete"] == '1'}checked{/if}> {#delete#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>

			<div class="table-row">
				<div class="table-cell-label">{#table_shop#}</div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="shop" {if $data.grants["shop"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="shop_view" {if $data.grants["shop_view"] == '1'}checked{/if}> {#view_detail#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="shop_edit" {if $data.grants["shop_edit"] == '1'}checked{/if}> {#edit#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="shop_delete" {if $data.grants["shop_delete"] == '1'}checked{/if}> {#delete#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>


			<div class="table-row">
				<div class="table-cell-label">{#table_user#}</div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="user" {if $data.grants["user"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="user_view" {if $data.grants["user_view"] == '1'}checked{/if}> {#view_detail#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="user_edit" {if $data.grants["user_edit"] == '1'}checked{/if}> {#edit#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="user_delete" {if $data.grants["user_delete"] == '1'}checked{/if}> {#delete#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>

			<div class="table-row">
				<div class="table-cell-label">{#table_config#}</div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="config" {if $data.grants["config"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="config_view" {if $data.grants["config_view"] == '1'}checked{/if}> {#view_detail#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="config_edit" {if $data.grants["config_edit"] == '1'}checked{/if}> {#edit#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="config_delete" {if $data.grants["config_delete"] == '1'}checked{/if}> {#delete#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>

			<div class="table-row">
				<div class="table-cell-label">{#table_calendar#}</div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="calendar" {if $data.grants["calendar"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="calendar_view" {if $data.grants["calendar_view"] == '1'}checked{/if}> {#view_detail#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="calendar_edit" {if $data.grants["calendar_edit"] == '1'}checked{/if}> {#edit#}
					<span>&nbsp;&nbsp;</span>
					<input type="checkbox" value="1" rel="calendar_delete" {if $data.grants["calendar_delete"] == '1'}checked{/if}> {#delete#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>

			<div class="table-row">
				<div class="table-cell-label">{#languages#}</div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="languages" {if $data.grants["languages"] == '1'}checked{/if}> {#edit#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>
	{* end menu_configuration *}

			<br>
			<div class="table-row">
				<div class="table-cell-label"><b>{#menu_sys_reports#}</b></div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="sys_reports" {if $data.grants["sys_reports"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>
			<div class="table-row">
				<div class="table-cell-label">{#table_sys_oper#}</div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="sys_oper" {if $data.grants["sys_oper"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>
			<div class="table-row">
				<div class="table-cell-label">{#table_sys_logon#}</div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="sys_logon" {if $data.grants["sys_logon"] == '1'}checked{/if}> {#view_menu#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>

		{* special_grants *}
			<br>
			<div class="table-row">
				<div class="table-cell-label"><b>{#special_grants#}</b></div>
			</div>
			<div class="table-row">
				<div class="table-cell-label"></div>
				<div class="table-cell">
					<input type="checkbox" value="1" rel="view_all_suppliers" {if $data.grants["view_all_suppliers"] == '1'}checked{/if}> {#view_all_suppliers#}
					<span>&nbsp;&nbsp;</span>
				</div>
			</div>

		{* end special_grants *}
		</div>


		<hr>
		<div class="table-row">
			<div class="table-cell-label"></div>
			<div class="table-cell">
				<input id="is_active" class="" type="checkbox" name="is_active" value="1" {if $data.is_active}checked="checked"{/if}>&nbsp;{#is_active#}
			</div>
		</div>

		<input type="hidden" value="" name="grants" id="grants">
	</div>

	{include file='configuration/btn_save_delete.tpl'}
</div>

<script type="text/javascript">
	$('#checkAllButton', '#nomedit').click (function () {
		$(':input', '#gratns_flags').prop('checked', true);
	});
	$('#uncheckAllButton', '#nomedit').click (function () {
		$(':input', '#gratns_flags').prop('checked', false);
	});

	function callbackSave() {
		var data = {};
		$('input:checked', '#gratns_flags').each( function() {
			data[$(this).attr('rel')] = this.value;
		});
		// Само ако има редове, записваме JSON във data_line. Иначе го оставяме празно
		if (!jQuery.isEmptyObject( data ))
			$('#grants', '#edit').val(JSON.stringify(data));
		else
			$('#grants', '#edit').val("");
		return true;
	}
</script>