{extends file="layout.tpl"}
{block name=content}
<div id="main">
	<div class="headerrow" id="headerrow">
		{include file='configuration/btn_add.tpl'}
		{if $smarty.session.userdata.user_id == '1'}
		<span class="" style="padding-left: 10px;">
			<button class="submit_button" id="submit_button"><span>{#btn_submit#}</span></button>
		</span>
		{/if}
		{include file='main_menu/list_search.tpl'}
		{*<button id="mass_mailing" class="submit_button" title="Масово изпращане на мейли до първите 100 потребителя, които имат въведен e-mail и до които още не са изпратени.&#013;Не пита, а направо изпраща.&#013;След като им ги изпрати, отбелязва в тези потребители че са им изпратени мейли."><span>Mass Mailing</span></button>*}
	</div>

	<table id="table_id"></table>
</div>

<script type="text/javascript">
	function InitTable () {
		var _self = this;
		this.mainTable = $("#table_id");
		this.last_params = {};

		$('#table_id').addClass(dataTable_default_class);
		var config = {
			paging: true,
			"ajax": function (data, callback, settings) {
				datatables_ajax({ data:{}, callback:callback, settings:settings, url:'/configuration/user_ajax' });
			},
			columns: [
				{ title: "#", data: 'id', className: "dt-center td-no-padding",
					render: function ( data, type, row ) {
						if (type !== 'display') return data;
						/*{if $allow_edit}*/
						return '<a href="/configuration/{$smarty.session.table_edit}_edit/'+row.id+'" rel="edit-'+row.id+'" edit_delete="{$smarty.session.table_edit}">'+displayDIV100(data)+'</a>';
						/*{else}*/
						return displayDIV100(data);
						/*{/if}*/
					}
				},
				{ title: "{#is_active#}", data: 'is_active', className: "dt-center td-no-padding auto_filter", render: displayCheckbox },
				{ title: "{#user_name#}", data: 'user_name', className: "td-no-padding", 
					render: function ( data, type, row ) {
						data = escapeHtml(data);
						if (type !== 'display') return data;
						/*{if $allow_edit}*/
						return '<a href="/configuration/{$smarty.session.table_edit}_edit/'+row.id+'" rel="edit-'+row.id+'" edit_delete="{$smarty.session.table_edit}">'+displayDIV100(data)+'</a>';
						/*{else}*/
						return displayDIV100(data);
						/*{/if}*/
					}
				},
				{ title: "{#user_role_name#}", data: 'user_role_name', className: "auto_filter", {*className: "td-no-padding",
					render: function ( data, type, row ) {
						data = escapeHtml(data);
						if (type !== 'display') return data;
						if (!data) data = '';
						//{if $smarty.session.userdata.grants.user_edit == '1' || $smarty.session.userdata.grants.user_view == '1'}
						return '<a href="/configuration/user_role_edit/'+row.user_role_id+'" rel="edit-'+row.user_role_id+'" title="{#Edit#} {#table_user_role#}">'+displayDIV100(data)+'</a>';
						//{else}
						return displayDIV100(data);
						//{/if}
					}
					*}
				},
				{ title: "{#org_id#}", data: 'org_id', className: "dt-right", render: EsCon.formatIntegerHideZero },
				{ title: "{#table_org#}", data: 'org_name', className: "td-no-padding",
					render: function ( data, type, row ) {
						data = escapeHtml(data);
						if (type !== 'display') return data;
						if (!data) data = '';
						/*{if $smarty.session.userdata.grants.org_edit == '1' || $smarty.session.userdata.grants.org_view == '1'}*/
						return '<a href="/configuration/org_edit/'+row.org_id+'" rel="edit-'+row.org_id+'" title="{#Edit#} {#table_org#}">'+displayDIV100(data)+'</a>';
						/*{else}*/
						return displayDIV100(data);
						/*{/if}*/
					}
				},
				{ title: "{#email#}", data: 'user_email', className: "ellipsis", render: displayEllipses },

				{ title: "{#w_group_name#}", data: 'w_group_name', className: "", render: escapeHtml },
				{ title: "{#warehouse_code#}", data: 'warehouse_code', className: "", render: escapeHtml },

				{ title: "{#full_name#}", data: 'user_full_name', render: escapeHtml },
				{ title: "{#phone#}", data: 'user_phone', render: escapeHtml },

				//{ title: "{#mo_date#}", data: 'mo_date', className: "dt-center",	render: EsCon.formatCRDate },
				//{ title: "{#mo_user_name#}", data: 'mo_user_name' },
			],
			initComplete: function () {
				_self.select_row();
			},
		} // Datatable


		this.select_row = function() {
			oTable.columns('.auto_filter').every(function (index) {
				datatable_set_auto_filter_column(this, null, false);
			});

			// Да маркираме като selected последно редактирания запис
			var id = edit_id || {$smarty.session["{$smarty.session.table_edit}_id"]|default:0};
			oTable.rows('#'+id).select();
			oTable.row({ selected: true }).show().draw(false);

			closeWaitingDialog();
		}

		// Добавяне на tfoot
		//this.mainTable.append("<tfoot>" + '<tr>'+config.columns.map(function () { return "<td></td>"; }).join("")+'</tr>' + "</tfoot>");
		oTable = this.mainTable.DataTable(config);
		datatable_add_btn_excel();

		$('#submit_button', '#headerrow').click( function () {
			oTable.rows({ selected: true }).deselect();
			oTable.ajax.reload( _self.select_row );
		});

		commonInitMFP();
	} // InitTable

	function fancyboxSaved() {
		commonFancyboxSaved('/configuration/list_refresh/{$smarty.session.table_edit}/' + edit_id, edit_id);
	}
	function fancyboxDeleted() {
		commonFancyboxDeleted();
	}

	var vTable;
	$(document).ready( function () {
		vTable = new InitTable;
	}); // $(document).ready


	{*
	$('#mass_mailing').click(function () {
		waitingDialog('Mass Mailing -> ...');
		jQuery.post('/configuration/mass_mailing', {}, function (result) {
			closeWaitingDialog();
			if (result)
				fnShowErrorMessage('', result);
			else
				location.reload();
		});
	});
	*}
</script>
{/block}