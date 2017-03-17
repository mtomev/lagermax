{$dont_include_lang=true}
{extends file="layout.tpl"}
{block name=content}
<div id="main" {*class="mfp-inline-holder"*}>
	<div id="aviso_edit" class="white-popup-block">
		{if $data.id > 0}
		<div class="header">{#Edit#} {#table_aviso#}</div>
		{else}
		<div class="header">{#Add#} {#table_aviso#}</div>
		{/if}
		<div class="nomedit-edit">
			<div style="display: table;">
				<div style="float: left;">
					<div class="table-row">
						<div class="table-cell-label">{#org_name#}</div>
						<div class="table-cell">
							<select id="org_id" class="text mandatory readonly" disabled> 
								{html_options options=$select_org selected=$data.org_id}
							</select>
						</div>
						<input type="hidden" name="org_id" value="{$data.org_id}">
					</div>
					<div class="table-row">
						<div class="table-cell-label">{#warehouse_name#}</div>
						<div class="table-cell">
							<select id="warehouse_id" class="text mandatory readonly" disabled>
								{html_options options=$select_warehouse selected=$data.warehouse_id}
							</select>
						</div>
						<input type="hidden" name="warehouse_id" value="{$data.warehouse_id}">
						<input type="hidden" name="warehouse_type" value="{$data.warehouse_type}">
					</div>


					<div class="table-row">
						<div class="table-cell-label">{#aviso_driver_name#}</div>
						<div class="table-cell">
							<input id="aviso_driver_name" class="text mandatory" type="text" maxlength="{$data.field_width.aviso_driver_name}" name="aviso_driver_name" value="{$data.aviso_driver_name}">
						</div>
					</div>
					<div class="table-row">
						<div class="table-cell-label">{#aviso_driver_phone#}</div>
						<div class="table-cell">
							<input id="aviso_driver_phone" class="text mandatory" type="text" maxlength="{$data.field_width.aviso_driver_phone}" name="aviso_driver_phone" value="{$data.aviso_driver_phone}">
						</div>
					</div>
					<div class="table-row">
						<div class="table-cell-label">{#aviso_truck_no#}</div>
						<div class="table-cell">
							<input id="aviso_truck_no" class="text mandatory" type="text" maxlength="{$data.field_width.aviso_truck_no}" name="aviso_truck_no" value="{$data.aviso_truck_no}">
						</div>
					</div>

					<div class="table-row">
						<div class="table-cell-label">{#aviso_truck_type#}</div>
						<div class="table-cell">
							<input class="checkbox" type="radio" name="aviso_truck_type" value="0" {if $data.aviso_truck_type == '0'}checked{/if}>&nbsp;{#aviso_truck_type_0#}
							<input class="checkbox" type="radio" name="aviso_truck_type" value="1" style="margin-left: 10px;" {if $data.aviso_truck_type == '1'}checked{/if}>&nbsp;{#aviso_truck_type_1#}
						</div>
					</div>
				</div>

				{* Time Slot *}
				<div id="time_slot" {*class="hidden"*} style="float: left; padding-left: 40px;">
					<div class="table-row">
						<div class="table-cell-label">{#aviso_date#}</div>
						<div class="table-cell">
							<input id="aviso_date" class="date readonly" data-type="Date" type="text" name="aviso_date" value="{$data.aviso_date}" readonly>
						</div>
					</div>

					<div class="table-row">
						<div class="table-cell-label">{#aviso_time#}</div>
						<div class="table-cell">
							<input id="aviso_time" class="time readonly" data-type="Time" type="text" name="aviso_time" value="{$data.aviso_time}" readonly>
						</div>
					</div>

					<div class="table-row">
						<div class="table-cell-label">{#aviso_status#}</div>
						<div class="table-cell">
							<input id="aviso_status" class="text10 readonly" type="text" value="{$data.aviso_status}" readonly>
						</div>
						<input type="hidden" name="aviso_status" value="{$data.aviso_status}">
					</div>

				</div>
			</div>


			{* Таблица с редовете от aviso_line *}
			<div class="" style="float: left;">
				<hr>
				<table id="table_line" class="row-border" style="width: 300px; margin: 0 0 !important;">
				</table>
			</div>
			<input type="hidden" id="qty_pallet_calc" name="qty_pallet_calc" value="">

			<input type="hidden" id="data_line" name="data_line" value="">
			<input type="hidden" id="deleted_line" name="deleted_line" value="">

			<input type="hidden" id="aviso_date_timeslot" name="aviso_date_timeslot" value="">
			<input type="hidden" id="aviso_time_timeslot" name="aviso_time_timeslot" value="">
		</div>


		<div class="row-button">
		{* Или потребителя може да редактира или е нов и потребителя може да добавя *}
		{if $data.allow_edit || ($smarty.session.userdata.grants.aviso_add == '1' && $data.id == 0)}
			<button class="save_button" id="save_button_aviso" title="{#select_timeslot#}"><span>{#btn_Next#}</span></button>
		{/if}
			<span>id:{$data.id}</span>
			<button class="cancel_button" id="cancel_button_aviso"><span>{#btn_Cancel#}</span></button>
		{if $data.allow_delete}
			<button class="delete_button" id="delete_button_aviso"><span>{#btn_Delete#}</span></button>
		{/if}
		</div>
		{include file='main_menu/status_line.tpl'}
	</div>
</div>

<script type="text/javascript">
	var ref = document.referer;
	callback_url = "{$callback_url}" || ref;

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
		
		this.empty_line = {$empty_line};
		this.counter = {$max_line_id};

		// Списъка със сгради, притежание на текущия company_id
		this.org_metro_list = {$select_org_metro};
		this.shop_list = {$select_shop};

		var config = {
			"bSort": false,
			searching: false,
			fixedHeader: false,
			data: _self.data_line,
			columns: [
				{ title: "#", name: 'id', data: 'id', className: "dt-center " },


				// org_metro_code
				{ title: "{#org_metro_code#}", name: 'org_metro_code', data: 'org_metro_code', className: "dt-center",
					render: function ( data, type, row ) {
						var shtml  = '<select row_id="'+row.id+'" ';
						shtml += 'name="org_metro_code" class="mandatory">';
						shtml += generate_select_option_2D(_self.org_metro_list, row.org_metro_code);
						shtml += '</select>';
						return shtml;
					}
				},

				// metro_request_no
				{ title: "{#metro_request_no#}", name: 'metro_request_no', data: 'metro_request_no', className: "",
					render: function ( data, type, row ) {
						if (!data) data = '';
						var shtml = '<input type="text" class="text30 mandatory" row_id="'+row.id+'" ';
						shtml += 'maxlength="'+_self.empty_line.field_width.metro_request_no+'" name="metro_request_no" value="'+data+'">';
						return shtml;
					}
				},

				/*{if $data.warehouse_type == '3'}*/
				// Метро магазин - само за 3 PAXD
				// shop_name, shop_id
				{ title: "{#shop_name#}", name: 'shop_name', data: 'shop_name', className: "",
					render: function ( data, type, row ) {
						var shtml  = '<select row_id="'+row.id+'" name="shop_id" class="mandatory">';
						shtml += generate_select_option_2D(_self.shop_list, row.shop_id);
						shtml += '</select>';
						return shtml;
					}
				},
				/*{/if}*/

				// qty_pallet
				{ title: "{#qty_pallet#}", name: 'qty_pallet', data: 'qty_pallet', className: "dt-right sum_footer_cnt",
					render: function ( data, type, row ) {
						data = EsCon.formatCount(data, type);
						if (!data) data = '';
						// Ако е въведено qty_pack, то това е забранено за попълване
						if (parseInt(row.qty_pack))
							var h_class = 'class="number-small readonly hidden" readonly';
						else
							var h_class = 'class="number-small mandatory"';
						var shtml  = '<input type="text" '+h_class+' data-type="Count" row_id="'+row.id+'" ';
						shtml += 'name="qty_pallet" value="'+data+'">';
						return shtml;
					}
				},
				/*{if $data.warehouse_type != '1'}*/
				// qty_pack
				{ title: "{#qty_pack#}", name: 'qty_pack', data: 'qty_pack', className: "dt-right sum_footer_cnt",
					render: function ( data, type, row ) {
						data = EsCon.formatCount(data, type);
						if (!data) data = '';
						// Ако е въведено qty_pallet, то това е забранено за попълване
						if (parseInt(row.qty_pallet))
							var h_class = 'class="number-small readonly hidden" readonly';
						else
							var h_class = 'class="number-small mandatory"';
						var shtml  = '<input type="text" '+h_class+' data-type="Count" row_id="'+row.id+'" ';
						shtml += 'name="qty_pack" value="'+data+'">';
						return shtml;
					}
				},
				/*{/if}*/

				/*{if $data.warehouse_type != '1'}*/
				// weight
				{ title: "{#weight#}", name: 'weight', data: 'weight', className: "dt-right sum_footer_qty",
					render: function ( data, type, row ) {
						data = EsCon.formatQuantity3(data, type);
						if (!data) data = '';
						var shtml  = '<input type="text" class="number mandatory" data-type="Quantity3" row_id="'+row.id+'" ';
						shtml += 'name="weight" value="'+data+'">';
						return shtml;
					}
				},
				/*{/if}*/
				/*{if $data.warehouse_type != '1'}*/
				// volume
				{ title: "{#volume#}", name: 'volume', data: 'volume', className: "dt-right sum_footer_qty",
					render: function ( data, type, row ) {
						data = EsCon.formatQuantity3(data, type);
						if (!data) data = '';
						var shtml  = '<input type="text" class="number mandatory" data-type="Quantity3" row_id="'+row.id+'" ';
						shtml += 'name="volume" value="'+data+'">';
						return shtml;
					}
				},
				/*{/if}*/

				// Изтриване на реда
				{ title: "", data: null, className: "dt-center td-no-padding",
					render: function ( data, type, row ) {
						var shtml = '<div class="delete-line" title="{#btn_removeLine#}">×</div>';
						return shtml;
					}
				},

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

				var $footer = $( api.column('org_metro_code:name').footer() );
				$footer.html('<button id="btn_addLine" class="add-line"><span>{#btn_addLine#}</span></button>');
				
				var qty_pallet_calc = datatable_get_footer_value(api, 'qty_pallet')
				/*{if $data.warehouse_type != '1'}*/
					+datatable_get_footer_value(api, 'qty_pack')/{$data.w_pack2pallet|default:1}
				/*{/if}*/
					;
				$('#aviso_edit #qty_pallet_calc').val(qty_pallet_calc);
				$footer = $( api.column('metro_request_no:name').footer() );
				$footer.html('{#qty_pallet_calc#}: '+qty_pallet_calc.toFixed(2));
			}
		} // Config


		this.localAfterRowAppend = function(edit_row) {
		// След инициализиране на таблицата, както и след добавяне на нов ред
			if (!edit_row)
				var element = '#table_line';
			else
				var element = edit_row.node();

			EsCon.set_mandatory($('.mandatory', element));
		} // localAfterRowAppend


		this.TableFinit = function() {
			$('#table_line tfoot').on('click', '#btn_addLine', function () {
				// !!! Трябва да се прави extend с {}, за да стане като Object, а не Array
				var data = jQuery.extend(true, {}, _self.empty_line);
				_self.counter++;
				
				data.id = _self.counter.toString();
				data.aviso_line_id = data.id;
				data.real_id = 0;

				data.qty_pallet = '0';
				data.qty_pack = '0';
				data.weight = '0';
				data.volume = '0';
				
				// Ако има само един метро код на Доставчки
				if (_self.org_metro_list.length == 2)
					data.org_metro_code = _self.org_metro_list[1].id;
				
				_self.data_line.push(data);
				var edit_row = _self.oTableLine.row.add( data )
				_self.oTableLine.rows().deselect();
				edit_row.draw().select();
				_self.localAfterRowAppend(edit_row);
				
				return false;
			});
			
			/*{if $data.id == 0}*/
			// Ако е ново Авизо, автоматично добавяне на един ред
			$('#btn_addLine', '#aviso_edit').trigger('click');
			/*{/if}*/

			_self.localAfterRowAppend();

			$('#table_line tbody').on("click", "input, select, textarea", function() {
				// Не е необходимо да селектвам текущия ред, защото <body> click ще го направи след това
				_self.oTableLine.rows().deselect();
			});

			$('#table_line tbody', '#aviso_edit').on('click', '.delete-line', function () {
				var row = _self.oTableLine.row($(this).parents("tr"));
				// Ако текущия ред не е selected
				if (!$(row).hasClass('selected')) {
					_self.oTableLine.rows().deselect();
					_self.oTableLine.row(row).select();
				}
				fnModalDialog('{#Confirm#}', '{#btn_removeLine#}', 
					function (row) {
						var data = row.data();

						// Ако е стар запис, добавяме в списъка от deleted_line
						if (parseInt(data.real_id))
							_self.deleted_line[data.real_id] = data.real_id;

						_self.data_line = _self.data_line.filter(function( obj ) {
							return obj.id !== data.id;
						});
						_self.data_line_old = _self.data_line_old.filter(function( obj ) {
							return obj.id !== data.id;
						});

						row.remove().draw( false );
					},
					row);
				return false;
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
				if (name == 'qty_pallet')
					_self.oTableLine.cell( $row, 'qty_pack:name' ).invalidate();
				if (name == 'qty_pack')
					_self.oTableLine.cell( $row, 'qty_pallet:name' ).invalidate();
				if (name == 'qty_pallet' || name == 'qty_pack' || name == 'weight' || name == 'volume') {
					_self.oTableLine.draw(false);
				}
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
			// Трябва да има поне един ред
			if (_self.data_line.length == 0) {
				fnShowErrorMessage('{#title_attention#}', '{#one_row_is_required#}!')
				return false;
			}

			var shop = {};
			/*{if $data.warehouse_type == '3'}*/
			// За 3 PAXD - максимум 3 реда за един Метро магазин
			// - ако има повече от един ред за един Метро магазин, то Метро код на доставчик трябва да е различен за всеки ред
			for (var i = 0, len = _self.data_line.length; i < len; i++) {
				shop['s'+_self.data_line[i].shop_id] = {
					shop_id: _self.data_line[i].shop_id,
					row_count: 0,
					org_metro_code: []
				}
			}
			/*{/if}*/

			for (var i = 0, len = _self.data_line.length; i < len; i++) {
				if (!checkRequiredSelect($("#table_line tbody tr#"+_self.data_line[i].id+" [name='org_metro_code'].mandatory", '#aviso_edit'), '{#org_metro_code#}'))
					return false;

				if (!checkRequired($("#table_line tbody tr#"+_self.data_line[i].id+" [name='metro_request_no'].mandatory", '#aviso_edit'), '{#metro_request_no#}'))
					return false;

				if (!checkRequiredSelect($("#table_line tbody tr#"+_self.data_line[i].id+" [name='shop_id'].mandatory", '#aviso_edit'), '{#shop_name#}'))
					return false;

				var qty_req_message = '{#qty_pallet#}';
				/*{if $data.warehouse_type != '1'}*/
				var qty_req_message = '{#qty_pallet#} или {#qty_pack#}';
				/*{/if}*/
				if (!checkRequiredNumeric($("#table_line tbody tr#"+_self.data_line[i].id+" [name='qty_pallet'].mandatory", '#aviso_edit'), qty_req_message))
					return false;
				if (!checkRequiredNumeric($("#table_line tbody tr#"+_self.data_line[i].id+" [name='qty_pack'].mandatory", '#aviso_edit'), qty_req_message))
					return false;
				if (!checkRequiredNumeric($("#table_line tbody tr#"+_self.data_line[i].id+" [name='weight'].mandatory", '#aviso_edit'), '{#weight#}'))
					return false;
				if (!checkRequiredNumeric($("#table_line tbody tr#"+_self.data_line[i].id+" [name='volume'].mandatory", '#aviso_edit'), '{#volume#}'))
					return false;


				/*{if $data.warehouse_type == '3'}*/
				shop['s'+_self.data_line[i].shop_id].row_count++;
				// За 3 PAXD - максимум 3 реда за един Метро магазин
				if (shop['s'+_self.data_line[i].shop_id].row_count > 3) {
					fnShowErrorMessage('{#title_attention#}', '{#max_3rows_per_shop#}!');
					return false;
				}
				// - ако има повече от един ред за един Метро магазин, то Метро код на доставчик трябва да е различен за всеки ред
				for (var j = 0, len1 = shop['s'+_self.data_line[i].shop_id].org_metro_code.length; j < len1; j++)
					if (shop['s'+_self.data_line[i].shop_id].org_metro_code[j] == _self.data_line[i].org_metro_code) {
						fnShowErrorMessage('{#title_attention#}', '{#org_metro_code_per_row_in_shop#}!');
						return false;
					}
				shop['s'+_self.data_line[i].shop_id].org_metro_code.push(_self.data_line[i].org_metro_code);
				/*{/if}*/


				// Ако е чисто нов, направо се включва
				if (_self.data_line[i].real_id == 0)
					data[_self.data_line[i].id] = _self.data_line[i];
				else
				if ( !linesIsEquals(_self.data_line[i], _self.data_line_old[i]) )
					data[_self.data_line[i].id] = _self.data_line[i];
			}
			// Само ако има редове, записваме JSON във data_line. Иначе го оставяме празно
			if (!jQuery.isEmptyObject( data ))
				$('#data_line', '#aviso_edit').val(JSON.stringify(data));
			else
				$('#data_line', '#aviso_edit').val("");

			if (!jQuery.isEmptyObject( _self.deleted_line ))
				$('#deleted_line', '#aviso_edit').val(JSON.stringify(_self.deleted_line));
			else
				$('#deleted_line', '#aviso_edit').val("");

			return true;
		}
	} // table_line
  // end Редовете от Авизото

	var vLocalTable;
	$(document).ready( function () {
	// Група от общи
		EsCon.set_datepicker('input.date', '#aviso_edit');
		// Това се прилага само за показаните със smarty променливи стойности в #aviso_edit, но не и за показаните с рендер функции в таблиците
		EsCon.set_number_val($('.number, .number-small, .time', '#aviso_edit'));
		// Да сложим attr placeholder на всички с .mandatory
		EsCon.set_mandatory($('#aviso_edit .mandatory'));

		// Ще ги задам така, защото по-късно динамично се добавят DOM елементи от същия вид
		$('#aviso_edit').on('focus', '.number, .number-small, .date, .time', EsCon.inputEvent.focusin);
		$('#aviso_edit').on('change', '.number, .number-small, .date, .time', EsCon.inputEvent.change);
		$('#aviso_edit').on('keydown', '.number, .number-small', EsCon.inputEvent.keydown);
	// край на Група от общи

		$('#aviso_status', '#aviso_edit').val(aviso_status($('#aviso_status', '#aviso_edit').val()));

		vLocalTable = new table_line;
	});

	$('#save_button_aviso', '#aviso_edit').click (function () {
		if (!EsCon.check_mandatory($('#aviso_edit .mandatory').not('#table_line .mandatory'))) return false;

		// Редовете от таблицата
		if (!vLocalTable.prepareToSave()) return;
		
		// Избор на времеви слот
		// warehouse_id, aviso_date, aviso_time, qty_pallet_calc
		var data = {
			aviso_id: {$data.id},
			warehouse_id: EsCon.getParsedVal($('#warehouse_id', '#aviso_edit')),
			warehouse_type: EsCon.getParsedVal($('#warehouse_type', '#aviso_edit')),
			aviso_date: EsCon.getParsedVal($('#aviso_date', '#aviso_edit')),
			aviso_time: EsCon.getParsedVal($('#aviso_time', '#aviso_edit')),
			qty_pallet_calc: EsCon.getParsedVal($('#qty_pallet_calc', '#aviso_edit')),
		};
		showMFP('/aviso/aviso_select_timeslot/{$data.id}', data);

		// Записа се извършва в aviso_select_timeslot.tpl
	});

	$('#cancel_button_aviso', '#aviso_edit').click (function () {
		window.location.href = callback_url;
	});
	$('#delete_button_aviso', '#aviso_edit').click (function () {
		fnDeleteDialog('/aviso/aviso_delete/{$data.id}', '{#table_aviso#}', '#main', false);
	});
	function fancyboxDeleted() {
		window.location.href = callback_url;
	}

</script>
{/block}
