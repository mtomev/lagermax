{extends file="layout.tpl"}
{block name=content}
{assign var="sub_menu" value=$smarty.session.sub_menu}
<div id="main">
	<div class="headerrow" id="headerrow">
		<span class="">
			{#w_group_name#}
			<select class="" id="w_group_id" name="w_group_id"> 
				{html_options options=$select_w_group selected={$smarty.session.$sub_menu.w_group_id}}
			</select>
		</span>
		<span class="">&nbsp;&nbsp;</span>

		{#aviso_date#}
		<input name="from_date" id="from_date" class="date" data-type="Date" type="text" style="width:80px;" value="{$smarty.session.$sub_menu.from_date}">
		<span class="">&nbsp;&nbsp;</span>

		<button class="submit_button" id="submit_button"><span>{#btn_submit#}</span></button>
	</div>

	<div id="timeslots" class="">
	</div>
</div>

<script type="text/javascript">
	var current_url = '{$current_url}';
	window.history.replaceState({ }, 'RealEstate', current_url);

	function localLoadData(params) {
		waitingDialog();
		$.ajax({
			url: '/reports/get_timeslot',
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
					// object[warehouse_code][working_day][timeslot] = { cnt_aviso, qty_pallet, qty_pack, weight, volume, qty_pallet_calc }
					var html = '';
					for (var warehouse_code in result) {
						html += '<div class="warehouse_code">';
						for (var working_day in result[warehouse_code]) {
							html += '<div class="working_day">';
							html += '<span style="font-weight: bold;">'+warehouse_code + ' / ' + EsCon.formatDate(working_day)+'</span>';
							html += '<br>';

							html += 
								'<table class="dataTable row-border hover" cellpadding="5" cellspacing="0" border="0" >'
									+'<thead>'
									+'<tr>'
										+'<th class="dt-center">{#aviso_time#}</th>'
										+'<th class="dt-right">{#cnt_aviso#}</th>'
										+'<th class="dt-right">{#qty_pallet#}</th>'
										+'<th class="dt-right">{#qty_pack#}</th>'
										+'<th class="dt-right">{#weight#}</th>'
										+'<th class="dt-right">{#volume#}</th>'
										+'<th class="dt-right">{#qty_pallet_calc#}</th>'
									+'</tr>'
									+'</thead>';
							for (var timeslot in result[warehouse_code][working_day]) {
								if (timeslot == '----')
									html += '<tr style="background-color: #F0F0F0;">';
								else
									html += '<tr>';
								html += 
									 '<td class="dt-center">'+timeslot+'</td>'
									+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[warehouse_code][working_day][timeslot].cnt_aviso)+'</td>'
									+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[warehouse_code][working_day][timeslot].qty_pallet)+'</td>'
									+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[warehouse_code][working_day][timeslot].qty_pack)+'</td>'
									+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[warehouse_code][working_day][timeslot].weight)+'</td>'
									+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[warehouse_code][working_day][timeslot].volume)+'</td>'
									+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[warehouse_code][working_day][timeslot].qty_pallet_calc)+'</td>'
								+'</tr>';
							}
							//html += "<tfoot>" + '<tr><td colspan="7" style="padding:0px;"></td>'+'</tr>' + "</tfoot>";
							html += '</table>';
							html += '</div>';
						}
						html += '</div>';
					}
					$('#timeslots').html(html);
				} else
					$('#timeslots').html('');
				closeWaitingDialog();
			} // success
		});
	} // localLoadData
	
	$(document).ready( function () {
		// Група от общи за всички номенклатури
		EsCon.set_datepicker('.date', '#headerrow');

		$('.number, .number-small, .date', '#headerrow').on('focus', EsCon.inputEvent.focusin);
		$('.number, .number-small, .date', '#headerrow').on('change', EsCon.inputEvent.change);
		$('#headerrow :input').not('#searchbox').on('keydown', function(e) {
			if(e.keyCode == 13) $('#submit_button', '#headerrow').trigger('click');
		});
		// край на Група от общи за всички номенклатури
		
		$('#submit_button', '#headerrow').trigger('click');
	});

	$('#submit_button', '#headerrow').click( function () {
		var params = {};
		params['w_group_id'] = $('#w_group_id', '#headerrow').val();
		params['from_date'] = EsCon.getParsedVal($('#from_date', '#headerrow'));

		localLoadData(params);
		//href_post(current_url, params );
	});
</script>
{/block}