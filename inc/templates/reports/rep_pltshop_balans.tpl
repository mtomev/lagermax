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
			{#aviso_date#}
			<input id="from_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.from_date}">
			<input id="to_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.to_date}">
		</span>

		<span class="" style="padding-left: 10px;">
			<button class="submit_button" id="submit_button"><span>{#btn_submit#}</span></button>
		</span>

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
			"ajax": function (data, callback, settings) {
				datatables_ajax({ data:_self.last_params, callback:callback, settings:settings, url:'/reports/rep_pltshop_balans_ajax' });
			},
			columns: [
				// shop_id
				{ title: '#', data: 'id', className: "dt-center td-no-padding",
					render: function ( data, type, row ) {
						data = escapeHtml(data);
						if (type !== 'display') return data;
						/*{if $smarty.session.userdata.grants.shop_edit == '1' || $smarty.session.userdata.grants.shop_view == '1'}*/
						return '<a href="/configuration/shop_edit/'+row.shop_id+'" rel="edit-'+row.shop_id+'" title="{#Edit#} {#table_shop#}">'+displayDIV100(data)+'</a>';
						/*{else}*/
						return displayDIV100(data);
						/*{/if}*/
					}
				},

				{ title: "{#shop_name#}", data: 'shop_name', className: "auto_filter ellipsis",
					//render: displayEllipses
					render: function ( data, type, row ) {
						data = escapeHtml(data);
						if (type !== 'display') return data;
						/*{if $smarty.session.userdata.grants.pltshop == '1'}*/
						return '<a href="javascript:;" url="/plt/pltshop" class="pltshop" title="{#menu_pltshop#}">'+displayDIV100(data)+'</a>';
						/*{else}*/
						return displayDIV100(data);
						/*{/if}*/
					}
				},

				{ title: "{#plt_eur#} {#balance_ns#}", data: 'ns_eur', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#plt_eur#} {#balance_in#}", data: 'in_eur', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#plt_eur#} {#balance_ret#}", data: 'ret_eur', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#plt_eur#} {#balance_claim#}", data: 'claim_eur', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#plt_eur#} {#balance_ks#}", data: 'ks_eur', className: "dt-right dt-body-gray sum_footer_0", render: EsCon.format0HideZero },

				{ title: "{#plt_chep#} {#balance_ns#}", data: 'ns_chep', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#plt_chep#} {#balance_in#}", data: 'in_chep', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#plt_chep#} {#balance_ret#}", data: 'ret_chep', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#plt_chep#} {#balance_claim#}", data: 'claim_chep', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#plt_chep#} {#balance_ks#}", data: 'ks_chep', className: "dt-right dt-body-gray sum_footer_0", render: EsCon.format0HideZero },

				{*
				{ title: "{#plt_other#} {#balance_ns#}", data: 'ns_other', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#plt_other#} {#balance_in#}", data: 'in_other', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#plt_other#} {#balance_ret#}", data: 'ret_other', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#plt_other#} {#balance_claim#}", data: 'claim_other', className: "dt-right sum_footer_0", render: EsCon.format0HideZero },
				{ title: "{#plt_other#} {#balance_ks#}", data: 'ks_other', className: "dt-right dt-body-gray sum_footer_0", render: EsCon.format0HideZero },
				*}

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
			oTable.row({ selected: true }).show().draw(false);


			$("#table_id tbody").off('click.pltshop').on('click.pltshop', 'a.pltshop', function(event) {
				$this = $(this);

				var url = $this.attr("url");
				if (!url)
					url = $this.attr("href");
				if (url === '') return;

				selectClickedRow(this);
				var params = {};
				params['shop_id'] = edit_row.data().shop_id;
				params['from_date'] = _self.last_params['from_date'];
				params['to_date'] = _self.last_params['to_date'];

				href_post(url, params, 'POST', '_blank' );
				return false;
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
		
		/*{*
		// Минимална От дата за Баланса
		$('#from_date', '#headerrow').datepicker( "option", "minDate", EsCon.formatDate('{$config_plt_balans_date}') );
		$('#from_date', '#headerrow').on('change', function () {
			var value = $(this).val();
			value = EsCon.parseDate(value);
			if (!value || value < '{$config_plt_balans_date}') {
				$(this).addClass('isnan');
				$(this).val(EsCon.formatDate('{$config_plt_balans_date}'));
			}
		});
		*}*/

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