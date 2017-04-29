{extends file="layout.tpl"}
{block name=content}
{assign var="sub_menu" value=$smarty.session.sub_menu}
<div id="main">
	<div id="headerrow">
	<div class="headerrow" style="float:left;">
		<span class="">
			{#w_group_name#}
			<select class="" id="w_group_id" name="w_group_id"> 
				{html_options options=$select_w_group selected={$smarty.session.$sub_menu.w_group_id}}
			</select>
		</span>
		<span class="" style="padding-left: 10px;">
			{#warehouse_code#}
			<select class="" id="warehouse_id" name="warehouse_id"> 
				{html_options options=$select_warehouse selected={$smarty.session.$sub_menu.warehouse_id}}
			</select>
		</span>
		<span class="ellipsis" style="padding-left: 10px;">
			{#org_name#}
			<select class="select2chosen" id="org_id" name="org_id" data-width="15rem;" {if $smarty.session.userdata.grants.view_all_suppliers != '1'}disabled{/if}> 
				{html_options options=$select_org selected={$smarty.session.$sub_menu.org_id}}
			</select>
			<span class="clear-input" id="org_id_clear">×</span>
		</span>
	</div>

	<div class="headerrow" style="clear:both; float:left; padding-top:0px;" id="datatable_add_btn_excel">
		<span class="">
			{#aviso_date#}
			<input name="from_date" id="from_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.from_date}">
			<input name="to_date" id="to_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.to_date}">
		</span>

		<span class="" style="padding-left: 10px;">
			{#aviso_status#}
			<select class="" id="aviso_status" name="aviso_status"> 
				{html_options options=$select_aviso_status selected={$smarty.session.$sub_menu.aviso_status}}
			</select>
		</span>

		<span class="" style="padding-left: 10px;">
			<button class="submit_button" id="submit_button"><span>{#btn_submit#}</span></button>
		</span>

		{include file='main_menu/list_search.tpl'}
	</div>
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
			_self.last_params['w_group_id'] = $('#w_group_id', '#headerrow').val();
			_self.last_params['warehouse_id'] = $('#warehouse_id', '#headerrow').val();
			_self.last_params['org_id'] = $('#org_id', '#headerrow').val();
			_self.last_params['aviso_status'] = $('#aviso_status', '#headerrow').val();

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


				{ title: "{#qty_pallet#}", data: 'qty_pallet', className: "dt-right sum_footer_0",	render: EsCon.format0HideZero },
				{ title: "{#qty_pack#}", data: 'qty_pack', className: "dt-right sum_footer_0",	render: EsCon.format0HideZero },
				{ title: "{#weight#}", data: 'weight', className: "dt-right sum_footer_3", render: EsCon.format3HideZero },
				{ title: "{#volume#}", data: 'volume', className: "dt-right sum_footer_3", render: EsCon.format3HideZero },

				{ title: "{#qty_pallet_calc#}", data: 'qty_pallet_calc', className: "dt-right sum_footer_2", render: EsCon.format2HideZero },

				{ title: "{#qty_pallet_rcvd#}", data: 'qty_pallet_rcvd', className: "dt-right sum_footer_0 qty_pallet_rcvd", render: EsCon.format0HideZero },
				{ title: "{#qty_pack_rcvd#}", data: 'qty_pack_rcvd', className: "dt-right sum_footer_0 qty_pack_rcvd", render: EsCon.format0HideZero },
				{ title: "{#qty_pallet_rcvd_calc#}", data: 'qty_pallet_rcvd_calc', className: "dt-right sum_footer_2", render: EsCon.format2HideZero },

				{ title: "{#aviso_status#}", name: 'aviso_status', data: 'aviso_status', render: aviso_status },

				{ title: "{#org_metro_code#}", name: 'org_metro_code', data: 'org_metro_code', className: "" },
				{ title: "{#metro_request_no#}", name: 'metro_request_no', data: 'metro_request_no', className: "" },
			],

			rowCallback: function (row, data, index) {
				// row e TR tag
				
				// aviso_status == '7'-приключено
				if (data.aviso_status == '7' && data.qty_pallet_rcvd != data.qty_pallet)
					$('td.qty_pallet_rcvd', row).addClass('isAttention');
				else
					$('td.qty_pallet_rcvd', row).removeClass('isAttention');

				if (data.aviso_status == '7' && data.qty_pack_rcvd != data.qty_pack)
					$('td.qty_pack_rcvd', row).addClass('isAttention');
				else
					$('td.qty_pack_rcvd', row).removeClass('isAttention');
			},

			"footerCallback": function( tfoot, data, start, end, display ) {
				var api = this.api();

				api.columns('.sum_footer_0', { 'search': 'applied' }).every(function (index) {
					datatable_set_footer(this, EsCon.format0);
				});
				api.columns('.sum_footer_2', { 'search': 'applied' }).every(function (index) {
					datatable_set_footer(this, EsCon.format2);
				});
				api.columns('.sum_footer_3', { 'search': 'applied' }).every(function (index) {
					datatable_set_footer(this, EsCon.format3);
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
			$("#table_id tbody").on("click", 'input, select, a', function() {
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
			oTable.rows().deselect();
			oTable.ajax.reload( _self.select_row, resetPaging );
		}

		// Добавяне на tfoot
		this.mainTable.append("<tfoot>" + '<tr>'+config.columns.map(function () { return "<td></td>"; }).join("")+'</tr>' + "</tfoot>");
		oTable = this.mainTable.DataTable(config);
		datatable_add_btn_excel($('#datatable_add_btn_excel'));

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


	// При смяна на w_group_id, да изтегля списъка от складовете
	// w_group_id, aviso_date, aviso_time, брой палети
	$('#w_group_id', '#headerrow').change(function () {
		var w_group_id = EsCon.getParsedVal($('#w_group_id', '#headerrow'));
		$.ajax({
			url: '/aviso/get_w_group_id_warehouse/'+w_group_id+'/warehouse_code',
			method: "POST",
			success: function (result) {
				try {
					var data = JSON.parse(result)
				}
				catch(err) {
					console.log(err);
					fnShowErrorMessage('', result);
					return false;
				}
				try {
					var html = generate_select_option_2D(data, 0, false);
					$('#warehouse_id', '#headerrow').empty().append(html);
				}
				catch(err) {
					console.log(result);
					fnShowErrorMessage('', err);
					return false;
				}
			} // success
		});
	});
	$("#org_id_clear", '#headerrow').on("click", function() {
		$('#org_id', '#headerrow').val(0).change();
		$('#org_id', '#headerrow').trigger("chosen:updated");
	});

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