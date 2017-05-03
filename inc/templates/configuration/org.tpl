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
			order: [[1, 'asc']],
			ajax: {
				url: '/configuration/org_ajax',
				type: "POST",
				dataSrc: function (result) {
					oTable.clear().columns().search('');
					//return result.data;

					// result.data е масива с данни result.fields е масива с имената на полетата
					var row = {};
					for ( var i=0, len=result.data.length; i<len; i++ ) {
						// За всеки ред се създава Object Json и с него се заменя стария ред
						row = {};
						for (j = 0, j_len = result.data[i].length; j < j_len; j++) {
							row[result.fields[j]] = result.data[i][j];
						}
						result.data[i] = row;
					}
					return result.data;
				},
			},
			columns: [
				{ title: "#", data: 'id', className: "dt-center" },
				{ title: "{#org_name#}", data: 'org_name', className: "td-no-padding",
					render: function ( data, type, row ) {
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
				{ title: "{#contact#}", data: 'org_contact' },
				{ title: "{#phone#}", data: 'org_phone',	className: "ellipsis", render: displayEllipses },
				{ title: "{#email#}", data: 'org_email',	className: "ellipsis", render: displayEllipses },

				{ title: "{#org_ns_plt_eur#}", data: 'org_ns_plt_eur', className: "dt-right", render: EsCon.format0HideZero },
				{ title: "{#org_ns_plt_chep#}", data: 'org_ns_plt_chep', className: "dt-right", render: EsCon.format0HideZero },
				{ title: "{#org_ns_plt_other#}", data: 'org_ns_plt_other', className: "dt-right", render: EsCon.format0HideZero },

				{ title: "{#note#}", data: 'org_note', className: "ellipsis", render: displayEllipses },

				{ title: "{#is_active#}", data: 'is_active', className: "dt-center td-no-padding",
					render: function ( data, type, row ) {
						return displayCheckbox(row.is_active);
					}
				},
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
		}
		oTable = this.mainTable.DataTable(config);
		datatable_add_btn_excel();

		$('#submit_button', '#headerrow').click( function () {
			oTable.ajax.reload( _self.select_row, false );
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