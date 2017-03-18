<div id="nomedit" class="white-popup-block">
	<div class="header">
	{if $data.id > 0}{#Edit#}{else}{#Add#}{/if} {#table_org#}
	</div>

	<div id="edit" class="nomedit-edit">
		<div class="table-row">
			<div class="table-cell-label">{#org_name#}</div>
			<div class="table-cell">
				<input id="org_name" class="text mandatory" type="text" maxlength="{$data.field_width.org_name}" name="org_name" value="{$data.org_name}">
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#address#}</div>
			<div class="table-cell">
				<textarea id="org_address" class="textarea" maxlength="{$data.field_width.org_address}" name="org_address">{$data.org_address}</textarea>
			</div>
		</div>

		<div class="table-row">
			<div class="table-cell-label">{#contact#}</div>
			<div class="table-cell">
				<input id="org_contact" class="text" type="text" maxlength="{$data.field_width.org_contact}" name="org_contact" value="{$data.org_contact}">
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#phone#}</div>
			<div class="table-cell">
				<input id="org_phone" class="text" type="text" maxlength="{$data.field_width.org_phone}" name="org_phone" value="{$data.org_phone}">
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#email#}</div>
			<div class="table-cell">
				<input id="org_email" class="text" type="text" maxlength="{$data.field_width.org_email}" name="org_email" value="{$data.org_email}">
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#note#}</div>
			<div class="table-cell">
				<textarea id="org_note" class="textarea" maxlength="{$data.field_width.org_note}" name="org_note">{$data.org_note}</textarea>
			</div>
		</div>
		
		<div class="table-row">
			<div class="table-cell-label"></div>
			<div class="table-cell">
				<input id="is_active" class="" type="checkbox" name="is_active" value="1" {if $data.is_active}checked="checked"{/if}>&nbsp;{#is_active#}
			</div>
		</div>

		{* Таблица с редовете от org_metro *}
		<div class="" style="height: auto;">
			<table id="table_org_metro" class="row-border" style="width: 300px; margin: 0 0 !important;">
			</table>
		</div>

		<input type="hidden" id="org_metro" name="org_metro" value="">
		<input type="hidden" id="deleted_org_metro" name="deleted_org_metro" value="">
	</div>

	{include file='configuration/btn_save_delete.tpl'}
</div>

<script type="text/javascript">
	var vTable;
	$(document).ready( function () {
		vTable = new table_org_metro({$data|json_encode}, {$data_line});

		// Автоматично разпъване на textarea
		$('textarea', '#nomedit').each(function () {
			textarea_auto_height(this);
		});
	});


  // Банкови сметки и другите events по общите данни
	function table_org_metro (org_data, org_data_line) {
		var _self = this;
		this.mainTable = $("#table_org_metro");

		this.org_data = org_data;
		// Съхраняваме data_line, за сравняване на въведените данни - дали има промяна
		// data_line е json_encode Array [ Object, ... ]
		this.data_line = org_data_line;
		this.data_line_old = jQuery.extend(true, [], _self.data_line);
		this.deleted_line = {};
		this.oTableLine;
		
		this.empty_line = {$empty_line};
		this.counter = 0; // брои отрицателно

		var config = {
			"bSort": false,
			searching: false,
			fixedHeader: false,
			data: _self.data_line,
			columns: [
				{ title: "#", data: 'id', className: "dt-center" },

				{ title: "{#org_metro_code#}", name: 'org_metro_code', data: 'org_metro_code', className: "",
					render: function ( data, type, row ) {
						if (!data) data = '';
						var shtml = '<input class="text30" type="text" row_id="'+row.id+'" ';
						shtml += 'maxlength="'+_self.empty_line.field_width.org_metro_code+'" name="org_metro_code" value="'+data+'">';
						return shtml;
					}
				},

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

				var $footer = $( api.column('org_metro_code:name').footer() );
				$footer.html('<button id="org_metro_btn_addLine" class="add-line"><span>{#btn_addLine#}</span></button>');
			}
		} // Config

		// Добавяне на tfoot
		_self.mainTable.append("<tfoot>" + '<tr>' + config.columns.map(function () { return "<td></td>"; }).join("") + '</tr>' + "</tfoot>");
		_self.oTableLine = _self.mainTable.DataTable(config);

		$('#table_org_metro tbody').on("click", "input, select, textarea", function(event) {
			// Не е необходимо да селектвам текущия ред, защото <body> click ще го направи след това
			_self.oTableLine.rows().deselect();
		});

		$('#table_org_metro tfoot').on('click', '#org_metro_btn_addLine', function () {
			// !!! Трябва да се прави extend с {}, за да стане като Object, а не Array
			var data = jQuery.extend(true, {}, _self.empty_line);
			_self.counter--;
			
			data.id = _self.counter.toString();
			data.org_metro_id = data.id;
			data.real_id = 0;
			_self.data_line.push(data);
			var edit_row = _self.oTableLine.row.add( data )
			_self.oTableLine.rows().deselect();
			edit_row.draw().select();
			_self.localAfterRowAppend(edit_row);
			
			// Фокусиране на org_metro_code
			edit_row.$('input[name=org_metro_code]').focus();

			return false;
		});
		
		this.localAfterRowAppend = function(edit_row) {
		// След инициализиране на таблицата, както и след добавяне на нов ред
			if (!edit_row)
				var element = '#table_org_metro';
			else
				var element = edit_row.node();

			// Трябва да се прикачи на елемент вътре в <tbody>, за да може после да сработи tbody.onclick
			// Обаче не се разпостранява върху добавените редове, затова го пъхам тук
			if (!edit_row)
				$('#table_org_metro tbody tr').on("click", "td input, td select, td textarea", function() {
					// Не е необходимо да селектвам текущия ред, защото <body> click ще го направи след това
					_self.oTableLine.rows().deselect();
				});
			else
				$(element).on("click", "td input, td select, td textarea", function() {
					// Не е необходимо да селектвам текущия ред, защото <body> click ще го направи след това
					_self.oTableLine.rows().deselect();
				});

		} // localAfterRowAppend

		_self.localAfterRowAppend();

		$('#table_org_metro tbody', '#nomedit').on('click', '.delete-line', function () {
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


		$('#table_org_metro tbody').on('change', 'input, select, textarea', function () {
			var $element = $(this);
			var value = EsCon.getParsedVal($element);
			if ($element.is(":checkbox"))
				value = $element.prop('checked') ? '1':'0';
			var name = $element.attr('name');
			var data = _self.oTableLine.row($element.parents("tr")).data();
			data[name] = value;
		});


		this.prepareToSave = function() {
			var data = {};
			for (var i = 0, len = _self.data_line.length; i < len; i++) {
				// Ако е чисто нов, направо се включва
				if (_self.data_line[i].real_id == 0)
					data[_self.data_line[i].id] = _self.data_line[i];
				else
				if ( !linesIsEquals(_self.data_line[i], _self.data_line_old[i]) )
					data[_self.data_line[i].id] = _self.data_line[i];
			}
			// Само ако има редове, записваме JSON във data_line. Иначе го оставяме празно
			if (!jQuery.isEmptyObject( data ))
				$('#org_metro', '#nomedit').val(JSON.stringify(data));
			else
				$('#org_metro', '#nomedit').val("");

			if (!jQuery.isEmptyObject( _self.deleted_line ))
				$('#deleted_org_metro', '#nomedit').val(JSON.stringify(_self.deleted_line));
			else
				$('#deleted_org_metro', '#nomedit').val("");

			return true;
		}
	} // table_org_metro

	function callbackSave() {
		if (!vTable.prepareToSave()) return;
		return true;
	}

</script>
