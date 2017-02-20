{extends file="layout.tpl"}
{block name=content}
<div id="main">
	<div class="headerrow" id="headerrow">
		<span class="">
			{#table_user#}
			<select class="param" id="user_id" name="user_id"> 
				{html_options options=$select_user selected={$smarty.session.sys_logon.user_id}}
			</select>
		</span>

		<span class="">
			<span class="">&nbsp;&nbsp;</span>
			{#from_date#}
			<input name="from_date" id="from_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.sys_logon.from_date}">

			<span class="">&nbsp;&nbsp;</span>
			{#to_date#}
			<input name="to_date" id="to_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.sys_logon.to_date}">


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

	var columns = {$columns};

	$(document).ready( function () {
		// Добавяне на tfoot
		var s = '';
		for (var i = 1, len = columns.length; i <= len; i++) { s += '<td></td>'; }
		s = '<tr>'+s+'</tr>';
		$('#table_id').append('<tfoot>'+s+s+'</tfoot>');

		$('#table_id').addClass(dataTable_default_class);
		oTable = $('#table_id').DataTable( {
			paging: true,
			data: {},
			columns: columns,

			initComplete: function () {
				datatable_auto_filter(this.api(), false);
			}

		}); // Datatable
		datatable_add_btn_excel();
	}); // $(document).ready



	$('#submit_button', '#headerrow').click( function () {
		var params = {};
		// user_id, from_date, to_date
		params['user_id'] = $('#user_id', '#headerrow').val();
		params['from_date'] = EsCon.getParsedVal($('#from_date', '#headerrow'), false);
		params['to_date'] = EsCon.getParsedVal($('#to_date', '#headerrow'), false);

		waitingDialog();

		$.ajax({
			url: '{$current_url}/search_button',
			method: "POST",
			//data: $('#headerrow').serialize(),
			data: params,
			success: function (data) {
				try {
					// parse и clear са бързи
					data = JSON.parse(data);
					oTable.clear().columns().search('');
					closeWaitingDialog();
					oTable.rows.add(data).draw();
					datatable_auto_filter(oTable, false);
				}
				catch(err) {
					closeWaitingDialog();
					//fnShowErrorMessage('{#title_error#}', err+'\n'+data);
					fnShowErrorMessage('{#title_error#}', err);
				}
			} // success
		});
		return false;
	});

</script>
{/block}