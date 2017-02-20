{extends file="layout.tpl"}
{block name=content}
<div id="main">
	<div class="headerrow" id="headerrow">
		<span class="">
			{#table_user#}
			<select class="param" id="user_id" name="user_id"> 
				{html_options options=$select_user selected={$smarty.session.sys_oper.user_id}}
			</select>
		</span>

		<span class="">
			<span class="">&nbsp;&nbsp;</span>
			{#from_date#}
			<input name="from_date" id="from_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.sys_oper.from_date}">

			<span class="">&nbsp;&nbsp;</span>
			{#to_date#}
			<input name="to_date" id="to_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.sys_oper.to_date}">

			<span class="">&nbsp;&nbsp;</span>
			<input type="checkbox" id="summarize" value="1" {if $smarty.session.sys_oper.summarize}checked="checked"{/if}/>
			{#summarize#}


			<span class="">&nbsp;&nbsp;</span>
			<button class="submit_button" id="submit_button"><span>{#btn_submit#}</span></button>
		</span>

	</div>

	<div>
	<table id="table_id"></table>
	</div>

</div>

<script type="text/javascript">
	var current_url = '{$current_url}';
	window.history.replaceState({ }, 'RealEstate', current_url);

	EsCon.set_datepicker('.date', '#headerrow');
	$('.number, .number-small, .date', '#headerrow').on('focus', EsCon.inputEvent.focusin);
	$('.number, .number-small, .date', '#headerrow').on('change', EsCon.inputEvent.change);
	$('#headerrow :input').not('#searchbox').on('keydown', function(e) {
		if(e.keyCode == 13) $('#submit_button', '#headerrow').trigger('click');
	});

	var data = {$data};

	$(document).ready( function () {
		$('#table_id').addClass(dataTable_default_class);
		oTable = $('#table_id').DataTable( {
		{if $smarty.session.sys_oper.summarize}
			data: data,
			columns: [
				{ title: "{#table_user#}", data: 'user_name' },
				{ title: "{#cnt_oper#}", name: 'cnt_oper', data: 'cnt_oper', className: "sum_footer_cnt dt-right", render: EsCon.formatCountHideZero },
			],
		{else}
			paging: true,
			data: data,
			columns: {$columns},

			initComplete: function () {
				if (data.length > 0) {
					datatable_auto_filter_column(this.api(), 'logon_id');
					datatable_auto_filter_column(this.api(), 'oper_name');
					datatable_auto_filter_column(this.api(), 'oper_type');
					datatable_auto_filter_column(this.api(), 'table_name');
					datatable_auto_filter_column(this.api(), 'user_name');
				}
			}
		{/if}

		}); // Datatable
		datatable_add_btn_excel();
	}); // $(document).ready




	$('#submit_button', '#headerrow').click( function () {
		var params = {};
		// user_id, from_date, to_date
		params['user_id'] = $('#user_id', '#headerrow').val();
		params['from_date'] = EsCon.getParsedVal($('#from_date', '#headerrow'), false);
		params['to_date'] = EsCon.getParsedVal($('#to_date', '#headerrow'), false);
		params['summarize'] = $('#summarize', '#headerrow').prop('checked') ? '1':'0';

		waitingDialog();
		href_post(current_url+'/execute', params );

		return false;
	});

</script>
{/block}