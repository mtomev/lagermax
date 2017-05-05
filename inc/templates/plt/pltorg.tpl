{extends file="layout.tpl"}
{block name=content}
{assign var="sub_menu" value=$smarty.session.sub_menu}
<div id="main">
	<div class="headerrow" id="headerrow">
		<span class="ellipsis">
			{#org_name#}
			<select class="select2chosen" id="org_id" data-width="15rem;" {if $smarty.session.userdata.grants.view_all_suppliers != '1'}disabled{/if}>
				{html_options options=$select_org selected={$smarty.session.$sub_menu.org_id}}
			</select>
			{if $smarty.session.userdata.grants.view_all_suppliers == '1'}
			<span class="clear-input" id="org_id_clear">×</span>
			{/if}
		</span>

		<span class="" style="padding-left: 10px;">
			{#pltorg_date#}
			<input id="from_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.from_date}">
			<input id="to_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.to_date}">
		</span>

		<span class="" style="padding-left: 10px;">
			<button class="submit_button" id="submit_button"><span>{#btn_submit#}</span></button>
		</span>

		{if $smarty.session.userdata.grants.pltorg_edit == '1'}
		<span class="" style="padding-left: 10px;">
			<button class="add_button" url="/plt/pltorg_edit/0" rel="edit-0" fullscreen="true" edit_add_new="{$smarty.session.table_edit}" title="{#Add#} {#table_pltorg#}"><span>{#add#}</span></button>
		</span>
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
			// pltorg_date, id
			order: [[2, 'asc'], [0, 'asc']],
			"ajax": function (data, callback, settings) {
				waitingDialog();
				var api = this.api();
				api.clear().columns().search('');
				$.ajax({
					url: '/plt/get_list_pltorg',
					method: "POST",
					data: _self.last_params,
					"dataType": "json",
					"cache": false,
					success: function (result) {
						if (result.hasOwnProperty('fields')) {
							// result.data е масива с данни result.fields е масива с имената на полетата
							var row = {};
							for ( var i=0, len=result.data.length; i<len; i++ ) {
								// За всеки ред се създава Object Json и с него се заменя стария ред
								row = {};
								for (j = 0, j_len = result.data[i].length; j < j_len; j++) {
									row[result.fields[j]] = result.data[i][j];
								}
								result.data[i] = row;
							}
						}
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
				{ title: "#", data: 'id', className: "dt-center td-no-padding", render: display_pltorg_edit },

				{ title: "{#org_name#}", data: 'org_name', className: "auto_filter ellipsis" , render: displayEllipses },

				{ title: "{#pltorg_date#}", data: 'pltorg_date', className: "dt-center",	render: EsCon.formatDate },

				{ title: "{#qty_plt_eur#}", data: 'qty_plt_eur', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#qty_plt_chep#}", data: 'qty_plt_chep', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#qty_plt_other#}", data: 'qty_plt_other', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },

				{ title: "{#qty_ret_plt_eur#}", data: 'qty_ret_plt_eur', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#qty_ret_plt_chep#}", data: 'qty_ret_plt_chep', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#qty_ret_plt_other#}", data: 'qty_ret_plt_other', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },

				{ title: "{#qty_claim_plt_eur#}", data: 'qty_claim_plt_eur', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#qty_claim_plt_chep#}", data: 'qty_claim_plt_chep', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#qty_claim_plt_other#}", data: 'qty_claim_plt_other', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },

				{*
				// Линк към PDF
				{ title: "{#scan_doc#}", data: 'scan_doc', className: "dt-center td-no-padding", 
					render: function ( data, type, row ) {
						return displayDocUpload( data, '/plt/pltorg_display/'+row.pltorg_id );
					}
				},
				*}

				{ title: "{#aviso_id#}", data: 'aviso_id', className: "dt-right", render: EsCon.formatIntegerHideZero },

				{ title: "{#pltorg_refnumb#}", data: 'pltorg_refnumb' },
				{ title: "{#pltorg_driver#}", data: 'pltorg_driver' },

				{ title: "{#note#}", data: 'pltorg_note', className: "ellipsis" , render: displayEllipses },

			],

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

			// Да маркираме като selected последно редактирания запис
			var id = edit_id || {$smarty.session["{$smarty.session.table_edit}_id"]|default:0};
			oTable.rows('#'+id).select().draw(false);
			// Те това е бавното - .draw(false) !!!
			oTable.row({ selected: true }).show().draw(false);

			// Заради Иконата за Upload
			$("#table_id tbody").on("click", 'input, select, a', function() {
				// Не е необходимо да селектвам текущия ред, защото <body> click ще го направи след това
				oTable.rows({ selected: true }).deselect();
			});

			closeWaitingDialog();
		} // select_row

		this.LoadData = function(resetPaging) {
			waitingDialog();
			setTimeout(function() {
				oTable.rows({ selected: true }).deselect();
				oTable.ajax.reload( _self.select_row, resetPaging );
			}, 10);
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