{extends file="layout.tpl"}
{block name=content}
<div id="main">
	<div class="headerrow">
		{include file='configuration/btn_add.tpl'}
	</div>

	<table id="table_id"></table>
</div>

<script type="text/javascript">
	$(document).ready( function () {
		$('#table_id').addClass(dataTable_default_class);
		oTable = $('#table_id').DataTable( {
			data: {$data},
			columns: [
				{ title: "#", data: 'id', className: "dt-center" },
				{ title: "{#name#}", data: 'config_name', className: "td-no-padding",
					render: function ( data, type, row ) {
						if (type !== 'display') return data;
						{if $allow_edit}
						return '<a href="/configuration/{$smarty.session.table_edit}_edit/'+row.id+'" rel="edit-'+row.id+'" edit_delete="{$smarty.session.table_edit}">'+displayDIV100(data)+'</a>';
						{else}
						return data;
						{/if}
					}
				},
				
				{ title: "{#config_value#}", data: 'config_value',	className: "ellipsis", render: displayEllipses },
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