{extends file="layout.tpl"}
{block name=content}
{assign var="sub_menu" value=$smarty.session.sub_menu}
<div id="main">
	<div class="headerrow" id="headerrow">
		<span class="ellipsis">
			{#org_name#}
			<select class="select2chosen" id="org_id" name="org_id" data-width="15rem;" {if $smarty.session.userdata.grants.view_all_suppliers != '1'}disabled{/if}> 
				{html_options options=$select_org selected={$smarty.session.$sub_menu.org_id}}
			</select>
		</span>
		<span class="">&nbsp;&nbsp;</span>

		{#aviso_date#}
		<input name="from_date" id="from_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.from_date}">
		<input name="to_date" id="to_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.to_date}">
		<span class="">&nbsp;&nbsp;</span>

		<button class="submit_button" id="submit_button"><span>{#btn_submit#}</span></button>

		{if $smarty.session.userdata.grants.aviso_add == '1'}
		<span class="">&nbsp;&nbsp;</span>
		<button class="add_button" url="/aviso/aviso_select_warehouse" rel="edit-0" edit_add_new="{$smarty.session.table_edit}" title="{#Add#} {#table_aviso#}"><span>{#add#}</span></button>
		{/if}

		{include file='main_menu/list_search.tpl'}
	</div>

	<table id="table_id">
	</table>

</div>

<script type="text/javascript">
	var current_url = '{$current_url}';
	window.history.replaceState({ }, '{#site_title#}', current_url);

	function InitTable () {
		var _self = this;
		this.mainTable = $("#table_id");
		this.last_params = {};

		this.SetParams = function() {
			_self.last_params['org_id'] = $('#org_id', '#headerrow').val();

			_self.last_params['from_date'] = EsCon.getParsedVal($('#from_date', '#headerrow'));
			_self.last_params['to_date'] = EsCon.getParsedVal($('#to_date', '#headerrow'));
		}
		_self.SetParams();

		$('#table_id').addClass(dataTable_default_class);
		var config = {
			paging: true,
			// aviso_date, aviso_time
			order: [[3, 'asc'], [4, 'asc']],
			"ajax": function (data, callback, settings) {
				var api = this.api();
				api.clear().columns().search('');
				$.ajax({
					url: '/aviso/get_list_aviso',
					method: "POST",
					data: _self.last_params,
					"dataType": "json",
					"cache": false,
					success: function (result) {
						callback( result );
					},
					"error": function (xhr, error, thrown) {
						api.clear().columns().search('').draw();
						if ( error == "parsererror" ) {
							//fnShowErrorMessage('', 'Invalid JSON response');
							fnShowErrorMessage('', xhr.responseText);
						}
						else if ( xhr.readyState === 4 ) {
							fnShowErrorMessage('', 'Ajax error');
						}
						else
							fnShowErrorMessage('', xhr.responseText);
					}
				});
			},

			columns: [
				{ title: "#", data: 'id', className: "dt-center td-no-padding", render: display_aviso_edit },

				{ title: "{#warehouse_code#}", data: 'warehouse_code', className: "auto_filter" },
				{ title: "{#org_name#}", data: 'org_name', className: "auto_filter ellipsis" , render: displayEllipses },

				{ title: "{#aviso_date#}", data: 'aviso_date', className: "dt-center",	render: EsCon.formatDate },
				{ title: "{#aviso_time#}", data: 'aviso_time', className: "dt-center",	render: EsCon.formatTime },

				// aviso_truck_type
				{ title: "{#aviso_truck_type#}", name: 'aviso_truck_type', data: 'aviso_truck_type', render: aviso_truck_type },

				{ title: "{#qty_pallet#}", data: 'qty_pallet', className: "dt-right sum_footer_cnt", render: EsCon.formatCountHideZero },
				{ title: "{#qty_pack#}", data: 'qty_pack', className: "dt-right sum_footer_cnt", render: EsCon.formatCountHideZero },
				{ title: "{#weight#}", data: 'weight', className: "dt-right sum_footer_qty3",	render: EsCon.formatQuantity3HideZero },
				{ title: "{#volume#}", data: 'volume', className: "dt-right sum_footer_qty3",	render: EsCon.formatQuantity3HideZero },

				{ title: "{#qty_pallet_calc#}", data: 'qty_pallet_calc', className: "dt-right sum_footer_qty",	render: EsCon.formatQuantityHideZero },

				// Линк към PDF
				{ title: "{#scan_doc#}", data: 'scan_doc', className: "dt-center td-no-padding", 
					render: function ( data, type, row ) {
						return displayDocUpload( data, '/aviso/aviso_display/'+row.aviso_id );
					}
				},

				{ title: "{#aviso_status#}", name: 'aviso_status', data: 'aviso_status', className: "td-no-padding",
					render: function ( data, type, row ) {
						if (type !== 'display') return data;
						data = aviso_status(data, type);
						/*{if $smarty.session.userdata.grants.aviso_reception_edit == '1' || $smarty.session.userdata.grants.aviso_reception_view == '1'}*/
						return '<a href="/aviso/aviso_edt_complete/'+row.aviso_id+'" rel="edit_'+row.aviso_id+'" title="{#aviso_complete#}">'+displayDIV100(data)+'</a>';
						/*{else}*/
						return displayDIV100(data);
						/*{/if}*/
					}
				},

				// aviso_truck_no
				{ title: "{#aviso_truck_no#}", data: 'aviso_truck_no' },
				// aviso_driver_name
				{ title: "{#aviso_driver_name#}", data: 'aviso_driver_name' },
				// aviso_driver_phone
				{ title: "{#aviso_driver_phone#}", data: 'aviso_driver_phone' },

				{ title: "{#aviso_start_exec#}", data: 'aviso_start_exec', className: "",	render: EsCon.formatDate },
				{ title: "{#aviso_end_exec#}", data: 'aviso_end_exec', className: "",	render: EsCon.formatDate },
				{ title: "{#note#}", data: 'aviso_reject_reason', className: "ellipsis" , render: displayEllipses },
			],

			"footerCallback": function( tfoot, data, start, end, display ) {
				var api = this.api();

				api.columns('.sum_footer_cnt', { 'search': 'applied' }).every(function (index) {
					datatable_set_footer(this, EsCon.formatCount);
				});
				api.columns('.sum_footer_qty', { 'search': 'applied' }).every(function (index) {
					datatable_set_footer(this, EsCon.formatQuantity);
				});
				api.columns('.sum_footer_qty3', { 'search': 'applied' }).every(function (index) {
					datatable_set_footer(this, EsCon.formatQuantity3);
				});
			},

			initComplete: function () {
				_self.select_row();
			},
		} // Datatable

		this.select_row = function() {
			oTable.columns('.auto_filter').every(function (index) {
				datatable_set_auto_filter_column(this, null, false);
			});
			datatable_auto_filter_column(oTable, 'aviso_truck_type', aviso_truck_type, false);
			datatable_auto_filter_column(oTable, 'aviso_status', aviso_status, false);

			// Да маркираме като selected последно редактирания запис
			var id = edit_id || {$smarty.session["{$smarty.session.table_edit}_id"]|default:0};
//var local_start = Date.now();
			oTable.rows('#'+id).select().draw(false);
			// Те това е бавното - .draw(false) !!!
			oTable.row({ selected: true }).show().draw(false);
			/*
			oTable.rows().every( function () {
				var row = this;
				if (row.data().id == id) {
					row.select().show().draw(false);
					return false;
				}
			});
			*/
//console.log('oTable.rows().every '+(Date.now() - local_start));

			// Заради Иконата за Upload
			$("#table_id tbody tr").on("click", 'td input, td select, td a', function() {
				// Не е необходимо да селектвам текущия ред, защото <body> click ще го направи след това
				oTable.rows().deselect();
			});
		}

		this.LoadData = function(resetPaging) {
			oTable.rows({ selected: true }).deselect();
			oTable.ajax.reload( _self.select_row, resetPaging );
		}

		// Добавяне на tfoot
		this.mainTable.append("<tfoot>" + '<tr>'+config.columns.map(function () { return "<td></td>"; }).join("")+'</tr>' + "</tfoot>");
		oTable = this.mainTable.DataTable(config);
		datatable_add_btn_excel();

		commonInitMFP();
	} // InitTable

	var vTable;
	$(document).ready( function () {
		EsCon.set_datepicker('.date', '#headerrow');
		$('.number, .number-small, .date', '#headerrow').on('focus', EsCon.inputEvent.focusin);
		$('.number, .number-small, .date', '#headerrow').on('change', EsCon.inputEvent.change);
		$('#headerrow :input').not('#searchbox, .chosen-search :input').on('keydown', function(e) {
			if(e.keyCode == 13) $('#submit_button', '#headerrow').trigger('click');
		});

		$("select.select2chosen:not(.hasChosen)", '#headerrow').each(function (idx, el) {
			select2chosen(el);
		});

		vTable = new InitTable;
	}); // $(document).ready


	$('#submit_button', '#headerrow').click( function () {
		vTable.SetParams();
		vTable.LoadData();
	});

	function fancyboxSaved() {
		vTable.LoadData(false);
	}
	function fancyboxDeleted() {
		vTable.LoadData(false);
	}
</script>
{/block}