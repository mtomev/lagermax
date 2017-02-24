{extends file="layout.tpl"}
{block name=content}
{assign var="sub_menu" value=$smarty.session.sub_menu}
<div id="main">
	<div class="headerrow" id="headerrow">
		<span class="">
			{#warehouse_code#}
			<select class="param" id="warehouse_id" name="warehouse_id"> 
				{html_options options=$select_warehouse selected={$smarty.session.$sub_menu.warehouse_id}}
			</select>
		</span>
		<span class="">&nbsp;&nbsp;</span>
		<span class="ellipsis">
			{#org_name#}
			<select class="param" id="org_id" name="org_id"> 
				{html_options options=$select_org selected={$smarty.session.$sub_menu.org_id}}
			</select>
		</span>
		<span class="">&nbsp;&nbsp;</span>

		{#aviso_date#}
		<input name="from_date" id="from_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.from_date}">
		<input name="to_date" id="to_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.to_date}">
		<span class="">&nbsp;&nbsp;</span>

		<button class="submit_button" id="submit_button"><span>{#btn_submit#}</span></button>

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
			_self.last_params['warehouse_id'] = $('#warehouse_id', '#headerrow').val();
			_self.last_params['org_id'] = $('#org_id', '#headerrow').val();

			_self.last_params['from_date'] = EsCon.getParsedVal($('#from_date', '#headerrow'));
			_self.last_params['to_date'] = EsCon.getParsedVal($('#to_date', '#headerrow'));
		}
		_self.SetParams();

		$('#table_id').addClass(dataTable_default_class);
		var config = {
			paging: true,
			// aviso_date, warehouse_code, aviso_time, aviso_id, shop_name
			order: [[1, 'asc'], [2, 'asc'], [3, 'asc'], [0, 'asc'], [4, 'asc']],

			"ajax": function (data, callback, settings) {
				var api = this.api();
				api.clear().columns().search('');
				$.ajax({
					url: '/aviso/get_list_aviso_detail',
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
			/* Това е алтернатива на горното, но горното е по-универсално
			"ajax": {
				url: '/aviso/get_list_aviso_detail',
				type: "POST",
				"data": function ( d ) {
					return $.extend( {}, d, _self.last_params );
				},
				dataSrc: function (result) {
					oTable.clear().columns().search('');
					return result.data;
				},
				"error": function (xhr, error, thrown) {
					oTable.clear().columns().search('');
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
			},
			*/
			columns: [
				{ title: "#", data: 'aviso_id', className: "dt-center td-no-padding", render: display_aviso_edit },

				{ title: "{#aviso_date#}", name: 'aviso_date', data: 'aviso_date', className: "dt-center auto_filter",	render: EsCon.formatDate },
				{ title: "{#warehouse_code#}", name: 'warehouse_code', data: 'warehouse_code', className: "auto_filter" },
				{ title: "{#aviso_time#}", data: 'aviso_time', className: "dt-center",	render: EsCon.formatTime },

				{ title: "{#shop_name#}", name: 'shop_name', data: 'shop_name', className: "auto_filter" },

				{ title: "{#org_name#}", data: 'org_name', className: "auto_filter ellipsis" , render: displayEllipses },


				{ title: "{#qty_pallet#}", data: 'qty_pallet', className: "dt-right sum_footer_cnt",	render: EsCon.formatCountHideZero },
				{ title: "{#qty_pack#}", data: 'qty_pack', className: "dt-right sum_footer_cnt",	render: EsCon.formatCountHideZero },
				{ title: "{#weight#}", data: 'weight', className: "dt-right sum_footer_qty3",	render: EsCon.formatQuantity3HideZero },
				{ title: "{#volume#}", data: 'volume', className: "dt-right sum_footer_qty3",	render: EsCon.formatQuantity3HideZero },

				{ title: "{#qty_pallet_calc#}", data: 'qty_pallet_calc', className: "dt-right sum_footer_qty",	render: EsCon.formatQuantityHideZero },

				{ title: "{#aviso_status#}", name: 'aviso_status', data: 'aviso_status', render: aviso_status },

				{ title: "{#org_metro_code#}", name: 'org_metro_code', data: 'org_metro_code', className: "" },
				{ title: "{#metro_request_no#}", name: 'metro_request_no', data: 'metro_request_no', className: "" },
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
			datatable_auto_filter_column(oTable, 'aviso_status', aviso_status, false);

			// Да маркираме като selected последно редактирания запис
			var id = edit_id || {$smarty.session["{$smarty.session.table_edit}_id"]|default:0};
//var local_start = Date.now();
			// По oTable.data()
			var data = oTable.data();
			var ids = [];
			for (var i = 0, len = data.length; i < len; i++) {
				if (data[i].aviso_id == id) 
					ids.push('#'+data[i].aviso_id+'-'+data[i].aviso_line_id);
			}
			oTable.rows(ids).select();
			// Те това е бавното - .draw(false) !!!
			//oTable.row({ selected: true }).show().draw(false);
//console.log('oTable.rows().every '+(Date.now() - local_start));


			// Заради Иконата за Upload
			$("#table_id tbody tr").on("click", 'td input, td select, td a', function() {
				// Не е необходимо да селектвам текущия ред, защото <body> click ще го направи след това
				oTable.rows().deselect();
			});

			// Скриване на колоната warehouse_code, ако е избран warehouse_id
			if (_self.last_params['warehouse_id'] && _self.last_params['warehouse_id'] != 0) {
				oTable.column('warehouse_code:name').visible(false);
			} else {
				oTable.column('warehouse_code:name').visible(true);
			}
			if (_self.last_params['from_date'] === _self.last_params['to_date'] && _self.last_params['from_date']) {
				oTable.column('aviso_date:name').visible(false);
			} else {
				oTable.column('aviso_date:name').visible(true);
			}
		}

		this.LoadData = function(resetPaging) {
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
		$('#headerrow :input').not('#searchbox').on('keydown', function(e) {
			if(e.keyCode == 13) $('#submit_button', '#headerrow').trigger('click');
		});

		vTable = new InitTable;
		//$('#submit_button', '#headerrow').trigger('click');
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