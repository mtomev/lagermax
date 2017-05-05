{extends file="layout.tpl"}
{block name=content}
{assign var="sub_menu" value=$smarty.session.sub_menu}
<div id="main">
	<div class="headerrow" id="headerrow">
		<span class="ellipsis">
			{#shop_name#}
			<select class="select2chosen" id="shop_id" data-width="13rem;">
				{html_options options=$select_shop selected={$smarty.session.$sub_menu.shop_id}}
			</select>
			<span class="clear-input" id="shop_id_clear">×</span>
		</span>

		<span class="" style="padding-left: 10px;">
			{#pltshop_date#}
			<input id="from_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.from_date}">
			<input id="to_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.to_date}">
		</span>

		<span class="" style="padding-left: 10px;">
			<button class="submit_button" id="submit_button"><span>{#btn_submit#}</span></button>
		</span>

		{if $smarty.session.userdata.grants.pltshop_edit == '1'}
		<span class="" style="padding-left: 10px;">
			<button class="add_button" url="/plt/pltshop_edit/0" rel="edit-0" fullscreen="true" edit_add_new="{$smarty.session.table_edit}" title="{#Add#} {#table_pltshop#}"><span>{#add#}</span></button>
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
			_self.last_params['shop_id'] = $('#shop_id', '#headerrow').val();

			_self.last_params['from_date'] = EsCon.getParsedVal($('#from_date', '#headerrow'));
			_self.last_params['to_date'] = EsCon.getParsedVal($('#to_date', '#headerrow'));
		}
		_self.SetParams();

		$('#table_id').addClass(dataTable_default_class);
		var config = {
			paging: true,
			// pltshop_date, id
			order: [[2, 'asc'], [0, 'asc']],
			"ajax": function (data, callback, settings) {
				var api = this.api();
				api.clear().columns().search('');
				$.ajax({
					url: '/plt/get_list_pltshop',
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
				{ title: "#", data: 'id', className: "dt-center td-no-padding", render: display_pltshop_edit },

				{ title: "{#shop_name#}", data: 'shop_name', className: "auto_filter ellipsis" , render: displayEllipses },

				{ title: "{#pltshop_date#}", data: 'pltshop_date', className: "dt-center",	render: EsCon.formatDate },

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
						return displayDocUpload( data, '/plt/pltshop_display/'+row.pltshop_id );
					}
				},
				*}

				{ title: "{#pltshop_refnumb#}", data: 'pltshop_refnumb' },
				{ title: "{#pltshop_driver#}", data: 'pltshop_driver' },

				{ title: "{#note#}", data: 'pltshop_note', className: "ellipsis" , render: displayEllipses },

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

	$("#shop_id_clear", '#headerrow').on("click", function() {
		$('#shop_id', '#headerrow').val(0).change();
		$('#shop_id', '#headerrow').trigger("chosen:updated");
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