{$dont_include_lang=true}
{extends file="layout.tpl"}
{block name=content}
<div id="main" {*class="mfp-inline-holder"*}>
	<div id="aviso_edit" class="white-popup-block">
		<div class="header">{#aviso_complete#}</div>

		<div class="nomedit-edit">
			<div style="display: table;">
				<div style="float: left;">
					<div class="table-row">
						<div class="table-cell-label">{#org_name#}</div>
						<div class="table-cell">
							<input class="text readonly" readonly type="text" value="{$data.org_name}">
						</div>
					</div>
					<div class="table-row">
						<div class="table-cell-label">{#warehouse_name#}</div>
						<div class="table-cell">
							<input class="text readonly" readonly type="text" value="{$data.warehouse_name}">
						</div>
					</div>


					<div class="table-row">
						<div class="table-cell-label">{#aviso_driver_name#}</div>
						<div class="table-cell">
							<input class="text readonly" readonly type="text" value="{$data.aviso_driver_name}">
						</div>
					</div>
					<div class="table-row">
						<div class="table-cell-label">{#aviso_driver_phone#}</div>
						<div class="table-cell">
							<input class="text readonly" readonly type="text" value="{$data.aviso_driver_phone}">
						</div>
					</div>
					<div class="table-row">
						<div class="table-cell-label">{#aviso_truck_no#}</div>
						<div class="table-cell">
							<input class="text readonly" readonly type="text" value="{$data.aviso_truck_no}">
						</div>
					</div>
				</div>

				{* Time Slot *}
				<div id="time_slot" {*class="hidden"*} style="float: left; padding-left: 40px;">
					<div class="table-row">
						<div class="table-cell-label">{#aviso_date#}</div>
						<div class="table-cell">
							<input class="date readonly" data-type="Date" type="text" value="{$data.aviso_date}" readonly>
						</div>
					</div>

					<div class="table-row">
						<div class="table-cell-label">{#aviso_time#}</div>
						<div class="table-cell">
							<input class="time readonly" data-type="Time" type="text" value="{$data.aviso_time}" readonly>
						</div>
					</div>

				</div>
			</div>


			{* Таблица с редовете от aviso_line *}
			<div class="" style="float: left; margin-bottom:20px;">
				<hr>
				<table id="table_line" class="row-border" style="width: 300px; margin: 0 0 !important;">
				</table>
			</div>
			<input type="hidden" id="qty_pallet_calc" name="qty_pallet_calc" value="">
			<input type="hidden" id="qty_pallet_rcvd_calc" name="qty_pallet_rcvd_calc" value="">
			<input type="hidden" id="data_line" name="data_line" value="">
			<input type="hidden" name="aviso_status_old" value="{$data.aviso_status_old}">

			<div style="display: table; clear: left;">
				<div class="table-cell-label">{#aviso_status#}</div>
				<div class="table-cell">
					<input id="aviso_status_old" class="text10 readonly" type="text" value="{$data.aviso_status_old}" readonly>
					&nbsp;-->&nbsp;
					<select id="aviso_status" name="aviso_status" class="text10"> 
						{html_options options=$select_aviso_status selected=$data.aviso_status}
					</select>
				</div>
				<span class="">&nbsp;&nbsp;</span>
				<div class="table-cell-label">{#note#}</div>
				<div class="table-cell">
					<textarea id="aviso_reject_reason" class="textarea" maxlength="{$data.field_width.aviso_reject_reason}" name="aviso_reject_reason">{$data.aviso_reject_reason}</textarea>
				</div>
			</div>
			<div style="display: table; clear: left;">
				<div class="table-cell-label">{#aviso_start_exec#}</div>
				<div class="table-cell">
					<input class="datetime readonly" data-type="Date" type="text" value="{$data.aviso_start_exec}" readonly>
				</div>
				<div class="table-cell-label">{#aviso_end_exec#}</div>
				<div class="table-cell">
					<input class="datetime readonly" data-type="Date" type="text" value="{$data.aviso_end_exec}" readonly>
				</div>
			</div>
		</div>


		<div class="row-button">
		{if $data.allow_edit}
			<button class="save_button" id="save_button_aviso"><span>{#btn_Save#}</span></button>
		{/if}
			<span>id:{$data.id}</span>
			<button class="cancel_button" id="cancel_button_aviso"><span>{#btn_Cancel#}</span></button>
			<a id="print_button_aviso_ppp" href="/aviso/aviso_ppp_display/{$data.id}/PPP_Aviso_{$data.id}.pdf" target="_blank" title="PPP_Aviso_{$data.id}.pdf" style="margin-left: 40px;">
				<img style="vertical-align: middle;" src="/images/pdf.png" alt="" border="0">
			</a>
		</div>
		{include file='main_menu/status_line.tpl'}
	</div>
</div>

<script type="text/javascript">
	var callback_url = "{$callback_url}" || document.referer;

  // Редовете от Авизото
	function table_line () {
		var _self = this;
		this.mainTable = $("#table_line");

		// Съхраняваме data_line, за сравняване на въведените данни - дали има промяна
		// data_line е json_encode Array [ Object, ... ]
		this.data_line = {$data_line};
		this.data_line_old = jQuery.extend(true, [], _self.data_line);
		this.deleted_line = {};
		this.oTableLine;

		// Ако aviso_status_old < '7', то да попълним с подразбиращи се стойности qty_pallet_rcvd и qty_pack_rcvd
		if ('{$data.aviso_status_old}' < '7') {
			for (var i = 0, len = _self.data_line.length; i < len; i++) {
				_self.data_line[i].qty_pallet_rcvd = _self.data_line[i].qty_pallet;
				_self.data_line[i].qty_pack_rcvd = _self.data_line[i].qty_pack;
			}
		}

		var config = {
			"bSort": false,
			searching: false,
			fixedHeader: false,
			data: _self.data_line,
			columns: [
				{ title: "#", name: 'id', data: 'id', className: "dt-center " },


				// org_metro_code
				{ title: "{#org_metro_code#}", name: 'org_metro_code', data: 'org_metro_code', className: "dt-center" },

				// metro_request_no
				{ title: "{#metro_request_no#}", name: 'metro_request_no', data: 'metro_request_no', className: "" },

				/*{if $data.warehouse_type == '3'}*/
				// Метро магазин - само за 3 PAXD
				// shop_name, shop_id
				{ title: "{#shop_name#}", name: 'shop_name', data: 'shop_name', className: "" },
				/*{/if}*/

				// qty_pallet
				{ title: "{#qty_pallet#}", name: 'qty_pallet', data: 'qty_pallet', className: "dt-right sum_footer_cnt", render: EsCon.formatCountHideZero },
				/*{if $data.warehouse_type != '1'}*/
				// qty_pack
				{ title: "{#qty_pack#}", name: 'qty_pack', data: 'qty_pack', className: "dt-right sum_footer_cnt", render: EsCon.formatCountHideZero },
				/*{/if}*/

				/*{if $data.warehouse_type != '1'}*/
				// weight
				{ title: "{#weight#}", name: 'weight', data: 'weight', className: "dt-right sum_footer_qty", render: EsCon.formatQuantity3 },
				/*{/if}*/
				/*{if $data.warehouse_type != '1'}*/
				// volume
				{ title: "{#volume#}", name: 'volume', data: 'volume', className: "dt-right sum_footer_qty", render: EsCon.formatQuantity3 },
				/*{/if}*/

				{ title: "{#qty_pallet_rcvd#}", name: 'qty_pallet_rcvd', data: 'qty_pallet_rcvd', className: "dt-right sum_footer_cnt",
					render: function ( data, type, row ) {
						data = EsCon.formatCount(data, type);
						if (!data) data = '';
						// Ако е въведено qty_pack_rcvd, то това е забранено за попълване
						if (parseInt(row.qty_pack_rcvd))
							var h_class = 'class="number-small readonly hidden" readonly';
						else
							var h_class = 'class="number-small '+(row.qty_pallet_rcvd!=row.qty_pallet?'isAttention':'')+'"';
						var shtml  = '<input type="text" '+h_class+' data-type="Count" row_id="'+row.id+'" ';
						shtml += 'name="qty_pallet_rcvd" value="'+data+'">';
						return shtml;
					}
				},
				/*{if $data.warehouse_type != '1'}*/
				// qty_pack_rcvd
				{ title: "{#qty_pack_rcvd#}", name: 'qty_pack_rcvd', data: 'qty_pack_rcvd', className: "dt-right sum_footer_cnt",
					render: function ( data, type, row ) {
						data = EsCon.formatCount(data, type);
						if (!data) data = '';
						// Ако е въведено qty_pallet_rcvd, то това е забранено за попълване
						if (parseInt(row.qty_pallet_rcvd))
							var h_class = 'class="number-small readonly hidden" readonly';
						else
							var h_class = 'class="number-small '+(row.qty_pack_rcvd!=row.qty_pack?'isAttention':'')+'"';
						var shtml  = '<input type="text" '+h_class+' data-type="Count" row_id="'+row.id+'" ';
						shtml += 'name="qty_pack_rcvd" value="'+data+'">';
						return shtml;
					}
				},
				/*{/if}*/

			],

			footerCallback: function (tfoot, data, start, end, display) {
				var api = this.api();
				footer_row = {};
				api.columns('.sum_footer_cnt').every(function (index) {
					datatable_set_footer(this, EsCon.formatCount);
				});
				api.columns('.sum_footer_qty').every(function (index) {
					datatable_set_footer(this, EsCon.formatQuantity3);
				});

				var qty_pallet_calc = datatable_get_footer_value(api, 'qty_pallet')
				/*{if $data.warehouse_type != '1'}*/
					+datatable_get_footer_value(api, 'qty_pack')/{$data.w_pack2pallet|default:1}
				/*{/if}*/
					;
				var qty_pallet_rcvd_calc = datatable_get_footer_value(api, 'qty_pallet_rcvd')
				/*{if $data.warehouse_type != '1'}*/
					+datatable_get_footer_value(api, 'qty_pack_rcvd')/{$data.w_pack2pallet|default:1}
				/*{/if}*/
					;
				$('#aviso_edit #qty_pallet_calc').val(qty_pallet_calc);
				$('#aviso_edit #qty_pallet_rcvd_calc').val(qty_pallet_rcvd_calc);

				$footer = $( api.column('metro_request_no:name').footer() );
				$footer.html('{#qty_pallet_calc#}: '+qty_pallet_calc.toFixed(2)+' / '+qty_pallet_rcvd_calc.toFixed(2));
			}
		} // Config


		this.TableFinit = function() {
			$('#table_line tbody').on("click", "input, select, textarea", function() {
				// Не е необходимо да селектвам текущия ред, защото <body> click ще го направи след това
				_self.oTableLine.rows().deselect();
			});

			// Запис на въведената стойност в масива
			$('#table_line tbody').on('change', 'input, select, textarea', function () {
				var $element = $(this);
				var value = EsCon.getParsedVal($element);
				if ($element.is(":checkbox"))
					value = $element.prop('checked') ? '1':'0';
				var name = $element.attr('name');
				var $row = $element.parents('tr');
				var data = _self.oTableLine.row($row).data();
				data[name] = value;
				
				_self.oTableLine.cell( $row, 'qty_pack_rcvd:name' ).invalidate();
				_self.oTableLine.cell( $row, 'qty_pallet_rcvd:name' ).invalidate();
				_self.oTableLine.draw(false);
			});
		}

		// Добавяне на tfoot
		_self.mainTable.append("<tfoot>" + '<tr>' + config.columns.map(function () { return "<td></td>"; }).join("") + '</tr>' + "</tfoot>");
		// Създаваме си таблицата
		_self.oTableLine = _self.mainTable.DataTable(config);
		_self.TableFinit();


		this.prepareToSave = function() {
			var data = {};
			$("#table_line tbody :input.isRequired").each( function() {
				$(this).removeClass('isRequired');
			});

			for (var i = 0, len = _self.data_line.length; i < len; i++) {
				if ( !linesIsEquals(_self.data_line[i], _self.data_line_old[i]) )
					data[_self.data_line[i].id] = _self.data_line[i];
			}
			// Само ако има редове, записваме JSON във data_line. Иначе го оставяме празно
			if (!jQuery.isEmptyObject( data ))
				$('#data_line', '#aviso_edit').val(JSON.stringify(data));
			else
				$('#data_line', '#aviso_edit').val("");

			return true;
		}
	} // table_line
  // end Редовете от Авизото

	var vLocalTable;
	$(document).ready( function () {
	// Група от общи
		EsCon.set_datepicker('input.date, input.datetime', '#aviso_edit');
		// Това се прилага само за показаните със smarty променливи стойности в #aviso_edit, но не и за показаните с рендер функции в таблиците
		EsCon.set_number_val($('.number, .number-small, .time', '#aviso_edit'));
		// Да сложим attr placeholder на всички с .mandatory
		EsCon.set_mandatory($('#aviso_edit .mandatory'));

		// Ще ги задам така, защото по-късно динамично се добавят DOM елементи от същия вид
		$('#aviso_edit').on('focus', '.number, .number-small, .date, .time', EsCon.inputEvent.focusin);
		$('#aviso_edit').on('change', '.number, .number-small, .date, .time', EsCon.inputEvent.change);
		$('#aviso_edit').on('keydown', '.number, .number-small', EsCon.inputEvent.keydown);
	// край на Група от общи

		$('#aviso_status_old', '#aviso_edit').val(aviso_status($('#aviso_status_old', '#aviso_edit').val()));

		vLocalTable = new table_line;
	});

	$('#save_button_aviso', '#aviso_edit').click (function () {
		$('#aviso_status_new', '#aviso_edit').val('7');
		if (!EsCon.check_mandatory($('#aviso_edit .mandatory').not('#table_line .mandatory'))) return false;

		// Редовете от таблицата
		if (!vLocalTable.prepareToSave()) return;
		
		$.ajax({
			type: 'POST',
			async: false,
			url: '/aviso/aviso_save_complete/{$data.id}',
			data: EsCon.serialize($('#aviso_edit :input').not('#table_line :input')),
			success: function (result) {
				if (!Number(result)) {
					closeWaitingDialog();
					fnShowErrorMessage('', result);
				}
				else {
					clickOpenFile('/aviso/aviso_ppp_display/'+result+'/PPP_Aviso_'+result+'.pdf');
					window.location.href = callback_url;
				}
			},
		});
	});

	$('#cancel_button_aviso', '#aviso_edit').click (function () {
		window.location.href = callback_url;
	});
</script>
{/block}
