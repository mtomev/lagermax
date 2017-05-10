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
				datatables_ajax({ data:{}, callback:callback, settings:settings, url:'/configuration/org_ajax' });
			},
			columns: [
				{ title: "#", data: 'id', className: "dt-center" },
				{ title: "{#is_active#}", data: 'is_active', className: "dt-center td-no-padding auto_filter", render: displayCheckbox },
				{ title: "{#org_name#}", data: 'org_name', className: "td-no-padding",
					render: function ( data, type, row ) {
						data = escapeHtml(data);
						if (type !== 'display') return data;
						/*{if $allow_view}*/
						return '<a href="/configuration/{$smarty.session.table_edit}_edit/'+row.id+'" rel="edit-'+row.id+'" edit_delete="{$smarty.session.table_edit}">'+displayDIV100(data)+'</a>';
						/*{else}*/
						return displayDIV100(data);
						/*{/if}*/
					}
				},
				{ title: "{#org_metro_code#}", data: 'org_metro_code',	className: "ellipsis", render: displayEllipses },
				{ title: "{#address#}", data: 'org_address',	className: "ellipsis", render: displayEllipses },
				{ title: "{#contact#}", data: 'org_contact', render: escapeHtml },
				{ title: "{#phone#}", data: 'org_phone',	className: "ellipsis", render: displayEllipses },
				{ title: "{#email#}", data: 'org_email',	className: "ellipsis", render: displayEllipses },

				{ title: "{#org_ns_plt_eur#}", data: 'org_ns_plt_eur', className: "dt-right", render: EsCon.format0HideZero },
				{ title: "{#org_ns_plt_chep#}", data: 'org_ns_plt_chep', className: "dt-right", render: EsCon.format0HideZero },
				{ title: "{#org_ns_plt_other#}", data: 'org_ns_plt_other', className: "dt-right", render: EsCon.format0HideZero },

				{ title: "{#note#}", data: 'org_note', className: "ellipsis", render: displayEllipses },

				{ title: "{#cnt_user#}", data: 'cnt_user', className: "dt-right auto_filter", render: EsCon.format0HideZero },
				{ title: "{#cnt_aviso#}", data: 'cnt_aviso', className: "dt-right auto_filter", render: EsCon.format0HideZero },
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

</script>
{/block}