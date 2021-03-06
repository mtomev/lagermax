{extends file="layout.tpl"}
{block name=content}
{assign var="sub_menu" value=$smarty.session.sub_menu}
<div id="main">
	<div id="headerrow">
	<div class="headerrow" style="float:left;">
		{if $smarty.session.userdata.grants.aviso_add == '1'}
		<span class="" style="padding-right: 10px;">
			<button class="add_button" url="/aviso/aviso_select_warehouse" rel="edit-0" edit_add_new="{$smarty.session.table_edit}" title="{#Add#} {#table_aviso#}"><span>{#add#}</span></button>
		</span>
		{/if}

		<span class="">
			{#w_group_name#}
			<select class="" id="w_group_id"> 
				{html_options options=$select_w_group selected={$smarty.session.$sub_menu.w_group_id}}
			</select>
		</span>
		<span class="ellipsis" style="padding-left: 10px;">
			{#org_name#}
			<select class="select2chosen" id="org_id" data-width="15rem;" {if $smarty.session.userdata.grants.view_all_suppliers != '1'}disabled{/if}> 
				{html_options options=$select_org selected={$smarty.session.$sub_menu.org_id}}
			</select>
			{if $smarty.session.userdata.grants.view_all_suppliers == '1'}
			<span class="clear-input" id="org_id_clear">×</span>
			{/if}
		</span>
	</div>

	<div class="headerrow" style="clear:both; float:left; padding-top:0px;" id="datatable_add_btn_excel">
		<span class="">
			{#aviso_date#}
			<input id="from_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.from_date}">
			<input id="to_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.to_date}">
		</span>

		<span class="" style="padding-left: 10px;">
			{#aviso_status#}
			<select class="" id="aviso_status"> 
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
			_self.last_params['org_id'] = $('#org_id', '#headerrow').val();
			_self.last_params['aviso_status'] = $('#aviso_status', '#headerrow').val();

			_self.last_params['from_date'] = EsCon.getParsedVal($('#from_date', '#headerrow'));
			_self.last_params['to_date'] = EsCon.getParsedVal($('#to_date', '#headerrow'));
		}
		_self.SetParams();

		$('#table_id').addClass(dataTable_default_class);
		var config = {
			paging: true,
			"ajax": function (data, callback, settings) {
				datatables_ajax({ data:_self.last_params, callback:callback, settings:settings, url:'/aviso/aviso_ajax' });
			},
			columns: [
				{ title: "#", data: 'id', className: "dt-center td-no-padding", render: display_aviso_edit },

				{ title: "{#warehouse_code#}", data: 'warehouse_code', className: "auto_filter", render: escapeHtml },
				{ title: "{#org_name#}", data: 'org_name', className: "auto_filter ellipsis" , render: displayEllipses },

				{ title: "{#aviso_date#}", data: 'aviso_date', className: "dt-center",	render: EsCon.formatDate },
				{ title: "{#aviso_time#}", data: 'aviso_time', className: "dt-center",	render: EsCon.formatTime },

				// aviso_truck_type
				{ title: "{#aviso_truck_type#}", name: 'aviso_truck_type', data: 'aviso_truck_type', render: aviso_truck_type },

				{ title: "{#qty_pallet#}", data: 'qty_pallet', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#qty_pack#}", data: 'qty_pack', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#weight#}", data: 'weight', className: "dt-right sum_footer_0",	render: EsCon.format0HideZero },
				{ title: "{#volume#}", data: 'volume', className: "dt-right sum_footer_3",	render: EsCon.format3HideZero },

				{ title: "{#qty_pallet_calc#}", data: 'qty_pallet_calc', className: "dt-right sum_footer_2",	render: EsCon.format2HideZero },

				// Линк към PDF
				{ title: "{#scan_doc#}", data: 'scan_doc', className: "dt-center td-no-padding", 
					render: function ( data, type, row ) {
						return displayDocUpload( data, '/aviso/aviso_display/'+row.aviso_id );
					}
				},

				{ title: "{#aviso_status#}", name: 'aviso_status', data: 'aviso_status', className: "td-no-padding",
					render: function ( data, type, row ) {
						if (type !== 'display') return data;
						var status = aviso_status(data, type);
						// {* 3-прието 7-приключено *}
						if (row.aviso_status != '3' && row.aviso_status != '7') {
							/*{if $smarty.session.userdata.grants.aviso_reception_edit == '1' || $smarty.session.userdata.grants.aviso_reception_view == '1'}*/
							return '<a href="javascript:;" url="/aviso/aviso_edit_receipt/'+row.aviso_id+'" class="aviso_edit_receipt" title="{#menu_aviso_reception#}">'+displayDIV100(status)+'</a>';
							/*{else}*/
							return displayDIV100(status);
							/*{/if}*/
						}
						else
						{
							/*{if $smarty.session.userdata.grants.aviso_reception_edit == '1' || $smarty.session.userdata.grants.aviso_reception_view == '1'}*/
							return '<a href="/aviso/aviso_edt_complete/'+row.aviso_id+'" rel="edit_'+row.aviso_id+'" title="{#aviso_complete#}">'+displayDIV100(status)+'</a>';
							/*{else}*/
							return displayDIV100(status);
							/*{/if}*/
						}
					}
				},

				// aviso_truck_no
				{ title: "{#aviso_truck_no#}", data: 'aviso_truck_no', render: escapeHtml },
				// aviso_driver_name
				{ title: "{#aviso_driver_name#}", data: 'aviso_driver_name', render: escapeHtml },
				// aviso_driver_phone
				{ title: "{#aviso_driver_phone#}", data: 'aviso_driver_phone', render: escapeHtml },

				{ title: "{#aviso_start_exec#}", data: 'aviso_start_exec', className: "",	render: EsCon.formatDate },
				{ title: "{#aviso_end_exec#}", data: 'aviso_end_exec', className: "",	render: EsCon.formatDate },
				{ title: "{#note#}", data: 'aviso_reject_reason', className: "ellipsis" , render: displayEllipses },

				{ title: "# lines", data: 'cnt_lines', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },

				{ title: "{#aviso_plt_eur#}", data: 'aviso_plt_eur', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#aviso_plt_chep#}", data: 'aviso_plt_chep', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#aviso_plt_other#}", data: 'aviso_plt_other', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },

				{ title: "{#aviso_ret_plt_eur#}", data: 'aviso_ret_plt_eur', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#aviso_ret_plt_chep#}", data: 'aviso_ret_plt_chep', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#aviso_ret_plt_other#}", data: 'aviso_ret_plt_other', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },

				{ title: "{#aviso_claim_plt_eur#}", data: 'aviso_claim_plt_eur', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#aviso_claim_plt_chep#}", data: 'aviso_claim_plt_chep', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#aviso_claim_plt_other#}", data: 'aviso_claim_plt_other', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },

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
			datatable_auto_filter_column(oTable, 'aviso_truck_type', aviso_truck_type, false);
			datatable_auto_filter_column(oTable, 'aviso_status', aviso_status, false);

			// Да маркираме като selected последно редактирания запис
			var id = edit_id || {$smarty.session["{$smarty.session.table_edit}_id"]|default:0};
//var local_start = Date.now();
			oTable.rows('#'+id).select().draw(false);
			// Те това е бавното - .show() !!!
			oTable.row({ selected: true }).show().draw(false);
//console.log('oTable.rows().every '+(Date.now() - local_start));

			// Заради Иконата за Upload
			$("#table_id tbody").off('click.deselect').on('click.deselect', 'input, select, a', function() {
				// Не е необходимо да селектвам текущия ред, защото <body> click ще го направи след това
				oTable.rows({ selected: true }).deselect();
			});

			$("#table_id tbody").off('click.aviso_edit_receipt').on('click.aviso_edit_receipt', 'a.aviso_edit_receipt', function(event) {
				is_edit_child = false;

				$this = $(this);

				var url = $this.attr("url");
				if (!url)
					url = $this.attr("href");
				var a_rel = $this.attr("rel");

				// Дали е нов елемент, който после се добавя в таблицата
				var edit_tr = $(this).parents("tr");
				edit_row = oTable.row(edit_tr);
				edit_id = edit_row.data().id;

				edit_delete = false;
				edit_add_new = false;
				if (url === '') return;
				showMFP(url, { }, '#aviso_id');
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