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
				{ title: "{#w_group_name#}", data: 'w_group_name', /*className: "td-no-padding",
					render: function ( data, type, row ) {
						if (type !== 'display') return data;
						{if $smarty.session.userdata.grants.w_group_edit == '1' || $smarty.session.userdata.grants.w_group_view == '1'}
						return '<a href="/configuration/w_group_edit/'+row.w_group_id+'" rel="edit-'+row.w_group_id+'" title="{#Edit#} {#table_w_group#}">'+displayDIV100(data)+'</a>';
						{else}
						return displayDIV100(data);
						{/if}
					}
					*/
				},
				{ title: "{#warehouse_name#}", data: 'warehouse_name', className: "td-no-padding",
					render: function ( data, type, row ) {
						if (type !== 'display') return data;
						{if $allow_view}
						return '<a href="/configuration/{$smarty.session.table_edit}_edit/'+row.id+'" rel="edit-'+row.id+'" edit_delete="{$smarty.session.table_edit}">'+displayDIV100(data)+'</a>';
						{else}
						return displayDIV100(data);
						{/if}
					}
				},
				{ title: "{#warehouse_code#}", data: 'warehouse_code' },
				{ title: "{#w_start_time#}", data: 'w_start_time', render: EsCon.formatTime },
				{ title: "{#w_end_time#}", data: 'w_end_time', render: EsCon.formatTime },
				{ title: "{#w_interval#}", data: 'w_interval', className: "dt-right", render: EsCon.formatCountHideZero },
				//{ title: "{#w_count#}", data: 'w_count', className: "dt-right", render: EsCon.formatCountHideZero },
				{ title: "{#w_max_pallet#}", data: 'w_max_pallet', className: "dt-right", render: EsCon.formatCountHideZero },
				{ title: "{#w_pack2pallet#}", data: 'w_pack2pallet', className: "dt-right", render: EsCon.formatCountHideZero },

				//{ title: "{#warehouse_template#}", data: 'warehouse_template' },
				{ title: "{#warehouse_type#}", data: 'warehouse_type', render: warehouse_type },
				{ title: "{#is_active#}", data: 'is_active', className: "dt-center td-no-padding",
					render: function ( data, type, row ) {
						return displayCheckbox(row.is_active);
					}
				},
			],

			// Да маркираме като selected последно редактирания запис
			initComplete: function () {
				/*{assign var="nomen_id" value="{$smarty.session.table_edit}_id"}*/
				var id = edit_id || {$smarty.session.$nomen_id|default:0};
				this.api().rows().every( function () {
					var row = this;
					if (row.data().{$nomen_id} == id) {
						row.select();
					return false;
				}
				});
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