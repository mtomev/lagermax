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

		<input type="checkbox" id="summarize" value="1" {if $smarty.session.$sub_menu.summarize}checked="checked"{/if}/>
		{#summarize#}
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
			url: '/reports/rep_timeslot_shop_ajax',
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
					// object[working_day][warehouse_code] = { cnt_aviso, qty_pallet, qty_pack, weight, volume, qty_pallet_calc }
					var html = '';
					if (params['summarize'] == '1') {
						html += '<div class="warehouse_code">';
						for (var working_day in result) {
							html += '<div class="working_day">';
							html += '<span style="font-weight: bold;">' + EsCon.formatDate(working_day)+'</span>';
							html += '<br>';

							html += 
								'<table class="dataTable row-border hover" cellpadding="5" cellspacing="0" border="0" >'
									+'<thead>'
									+'<tr>'
										+'<th class="dt-left">{#shop_name#}</th>'
										+'<th class="dt-right">{#cnt_aviso#}</th>'
										+'<th class="dt-right">{#qty_pallet#}</th>'
										+'<th class="dt-right">{#qty_pack#}</th>'
										+'<th class="dt-right">{#weight#}</th>'
										+'<th class="dt-right">{#volume#}</th>'
										+'<th class="dt-right">{#qty_pallet_calc#}</th>'
									+'</tr>'
									+'</thead>';
							for (var warehouse_code in result[working_day]) {
								html += '<tr>';
								html += '<td class="dt-left">'+warehouse_code+'</td>';
								html += 
									 '<td class="dt-right">'+EsCon.formatIntegerHideZero(result[working_day][warehouse_code].cnt_aviso)+'</td>'
									+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[working_day][warehouse_code].qty_pallet)+'</td>'
									+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[working_day][warehouse_code].qty_pack)+'</td>'
									+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[working_day][warehouse_code].weight)+'</td>'
									+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[working_day][warehouse_code].volume)+'</td>'
									+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[working_day][warehouse_code].qty_pallet_calc)+'</td>'
								+'</tr>';
							}
							html += '</table>';
							html += '</div>';
						}
						html += '</div>';
						$('#timeslots').html(html);
					}
					else
					{
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
									/*if (timeslot == '----')
										html += '<td class="dt-center">'+warehouse_code+'</td>';
									else*/
										html += '<td class="dt-center">'+timeslot+'</td>';
									html += 
										 '<td class="dt-right">'+EsCon.formatIntegerHideZero(result[warehouse_code][working_day][timeslot].cnt_aviso)+'</td>'
										+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[warehouse_code][working_day][timeslot].qty_pallet)+'</td>'
										+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[warehouse_code][working_day][timeslot].qty_pack)+'</td>'
										+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[warehouse_code][working_day][timeslot].weight)+'</td>'
										+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[warehouse_code][working_day][timeslot].volume)+'</td>'
										+'<td class="dt-right">'+EsCon.formatIntegerHideZero(result[warehouse_code][working_day][timeslot].qty_pallet_calc)+'</td>'
									+'</tr>';
								}
								html += '</table>';
								html += '</div>';
							}
							html += '</div>';
						}
						$('#timeslots').html(html);
					}
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
		params['summarize'] = $('#summarize', '#headerrow').prop('checked') ? '1':'0';

		localLoadData(params);
		//href_post(current_url, params );
	});
</script>
{/block}