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
			paging: true,
			data: {$data},
			columns: [
				{ title: "#", data: 'id', className: "dt-center" },
				{ title: "{#is_active#}", data: 'is_active', className: "dt-center td-no-padding auto_filter", render: displayCheckbox },
				{ title: "{#w_group_name#}", data: 'w_group_name', className: "td-no-padding",
					render: function ( data, type, row ) {
						data = escapeHtml(data);
						if (type !== 'display') return data;
						{if $allow_view}
						return '<a href="/configuration/{$smarty.session.table_edit}_edit/'+row.id+'" rel="edit-'+row.id+'" edit_delete="{$smarty.session.table_edit}">'+displayDIV100(data)+'</a>';
						{else}
						return displayDIV100(data);
						{/if}
					}
				},

				{ title: "{#w_group_address#}", data: 'w_group_address',	className: "ellipsis", render: displayEllipses },
			],

			initComplete: function () {
				this.api().columns('.auto_filter').every(function (index) {
					datatable_set_auto_filter_column(this, null, false);
				});

				// Да маркираме като selected последно редактирания запис
				var id = edit_id || {$smarty.session["{$smarty.session.table_edit}_id"]|default:0};
				this.api().rows('#'+id).select();
				this.api().row({ selected: true }).show().draw(false);
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