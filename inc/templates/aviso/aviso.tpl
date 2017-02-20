{extends file="layout.tpl"}
{block name=content}
{assign var="sub_menu" value=$smarty.session.sub_menu}
<div id="main">
	<div class="headerrow" id="headerrow">
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
		var self = this;
		this.mainTable = $("#table_id");
		this.last_params = {};

		$('#table_id').addClass(dataTable_default_class);
		var config = {
			paging: true,
			// aviso_date, aviso_time
			order: [[3, 'asc'], [4, 'asc']],
			data: {},
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

				{ title: "{#aviso_status#}", name: 'aviso_status', data: 'aviso_status', render: aviso_status },

				// aviso_truck_no
				{ title: "{#aviso_truck_no#}", data: 'aviso_truck_no' },
				// aviso_driver_name
				{ title: "{#aviso_driver_name#}", data: 'aviso_driver_name' },
				// aviso_driver_phone
				{ title: "{#aviso_driver_phone#}", data: 'aviso_driver_phone' },
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

		} // Datatable

		this.select_row = function() {
			oTable.columns('.auto_filter').every(function (index) {
				datatable_set_auto_filter_column(this, null, false);
			});
			datatable_auto_filter_column(oTable, 'aviso_truck_type', aviso_truck_type, false);
			datatable_auto_filter_column(oTable, 'aviso_status', aviso_status, false);

			// Да маркираме като selected последно редактирания запис
			{assign var="nomen_id" value="{$smarty.session.table_edit}_id"}
			var id = edit_id || {$smarty.session.$nomen_id|default:0};
			oTable.rows().every( function () {
				var row = this;
				if (row.data().{$nomen_id} == id) {
					row.select();
					return false;
				}
			});

			// Заради Иконата за Upload
			$("#table_id tbody tr").on("click", 'td input, td select, td a', function() {
				// Не е необходимо да селектвам текущия ред, защото <body> click ще го направи след това
				oTable.rows().deselect();
			});
		}

		this.LoadData = function(params) {
			if (typeof(params)==='undefined') {
				params = self.last_params;
			} else
				self.last_params = jQuery.extend(true, [], params);
			waitingDialog();
			$.ajax({
				url: '/aviso/get_list_aviso',
				method: "POST",
				data: params,
				success: function (result) {
					try {
						if (result)
							result = JSON.parse(result);
					}
					catch(err) {
						closeWaitingDialog();
						fnShowErrorMessage('', result);
						console.log(err);
						return;
					}
					if (result) {
						oTable.clear().columns().search('').rows.add(result);
					} else
						oTable.clear().columns().search('');
					closeWaitingDialog();
					oTable.draw();
					self.select_row();
				} // success
			});
		}

		// Добавяне на tfoot
		this.mainTable.append("<tfoot>" + '<tr>'+config.columns.map(function () { return "<td></td>"; }).join("")+'</tr>' + "</tfoot>");
		oTable = this.mainTable.DataTable(config);
		datatable_add_btn_excel();


		commonInitMFP();

	} // InitTable

	function fancyboxSaved() {
		vTable.LoadData();
		//commonFancyboxSaved('/configuration/list_refresh/aviso/' + edit_id, edit_id);
	}
	function fancyboxDeleted() {
		vTable.LoadData();
		//commonFancyboxDeleted();
	}


	var vTable;
	$(document).ready( function () {
		vTable = new InitTable;

		EsCon.set_datepicker('.date', '#headerrow');
		$('.number, .number-small, .date', '#headerrow').on('focus', EsCon.inputEvent.focusin);
		$('.number, .number-small, .date', '#headerrow').on('change', EsCon.inputEvent.change);
		$('#headerrow :input').not('#searchbox').on('keydown', function(e) {
			if(e.keyCode == 13) $('#submit_button', '#headerrow').trigger('click');
		});

		$('#submit_button', '#headerrow').trigger('click');
	}); // $(document).ready


	$('#submit_button', '#headerrow').click( function () {
		var params = {};
		params['org_id'] = $('#org_id', '#headerrow').val();

		params['from_date'] = EsCon.getParsedVal($('#from_date', '#headerrow'));
		params['to_date'] = EsCon.getParsedVal($('#to_date', '#headerrow'));

		vTable.LoadData(params);
	});
</script>
{/block}