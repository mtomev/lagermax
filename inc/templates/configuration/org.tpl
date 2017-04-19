{extends file="layout.tpl"}
{block name=content}
<div id="main">
	<div class="headerrow" id="headerrow">
		{include file='configuration/btn_add.tpl'}
		{include file='main_menu/list_search.tpl'}
	</div>

	<table id="table_id"></table>
</div>

<script type="text/javascript">
	$(document).ready( function () {
		$('#table_id').addClass(dataTable_default_class);
		oTable = $('#table_id').DataTable( {
			order: [[1, 'asc']],
			paging: true,
			//data: { },
			ajax: {
				url: '/configuration/org_ajax',
				type: "POST",
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
				{ title: "{#cnt_user#}", data: 'cnt_user', className: "dt-right", render: EsCon.format0HideZero },
			],

			// Да маркираме като selected последно редактирания запис
			initComplete: function () {
				var id = edit_id || {$smarty.session["{$smarty.session.table_edit}_id"]|default:0};
				oTable.rows('#'+id).select();
				oTable.row({ selected: true }).show().draw(false);
			}
		}); // Datatable
		datatable_add_btn_excel();

		commonInitMFP();
	}); // $(document).ready

	function fancyboxSaved() {
		commonFancyboxSaved('/configuration/list_refresh/{$smarty.session.table_edit}/' + edit_id, edit_id);
	}
	function fancyboxDeleted() {
		commonFancyboxDeleted();
	}
	
</script>
{/block}