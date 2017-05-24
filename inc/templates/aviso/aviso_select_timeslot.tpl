<div id="nomedit_timeslot" class="white-popup-block">

	<div class="header">
		<span>{#select_timeslot#}</span>
	</div>

	<div class="nomedit-edit">
		<div class="table-row">
			<div class="table-cell-label">{#aviso_date#}</div>
			<div class="table-cell">
				<select id="aviso_date_timeslot" class="text10 mandatory"> 
					{html_options options=$select_aviso_date selected=$data.aviso_date}
				</select>
			</div>
		</div>

		<div class="table-row">
			<div class="table-cell-label">{#aviso_time#}</div>
			<div class="table-cell">
				<select id="aviso_time_timeslot" class="text10 mandatory"> 
					{html_options options=$select_aviso_time selected=$data.aviso_time}
				</select>
			</div>
		</div>
	</div>

	<div class="row-button">
		<button class="save_button" id="save_button_timeslot"><span>{#btn_Save#}</span></button>
		<button class="cancel_button" id="cancel_button_timeslot"><span>{#btn_Cancel#}</span></button>
	</div>

</div>

<script type="text/javascript">
	EsCon.set_mandatory($('#nomedit_timeslot .mandatory'));

	// При смяна на Авизо датата, да изтегля свободните слотове за новата дата
	// warehouse_id, aviso_date, aviso_time, брой палети
	$('#aviso_date_timeslot', '#nomedit_timeslot').change(function () {
		var data = {
			aviso_id: {$data.id},
			warehouse_id: EsCon.getParsedVal($('#warehouse_id', '#aviso_edit')),
			warehouse_type: EsCon.getParsedVal($('#warehouse_type', '#aviso_edit')),
			aviso_date: EsCon.getParsedVal($('#aviso_date_timeslot', '#nomedit_timeslot')),
			aviso_time: EsCon.getParsedVal($('#aviso_time', '#aviso_edit')),
			qty_pallet_calc: EsCon.getParsedVal($('#qty_pallet_calc', '#aviso_edit')),
		};
		$.ajax({
			url: "/aviso/get_aviso_timeslot/{$data.id}",
			method: "POST",
			data: data,
			success: function (result) {
				try {
					var data = JSON.parse(result)
				}
				catch(err) {
					console.log(err);
					fnShowErrorMessage('', result);
					return false;
				}
				try {
					var html = '';
					for (var key in data) {
						html += '<option value="'+key+'"';
						if ( data[key] == '{$data.aviso_time}' )
							html += ' selected';
						html += '>'+data[key]+'</option>';
					}
					$('#nomedit_timeslot #aviso_time_timeslot').empty().append(html);
				}
				catch(err) {
					console.log(result);
					fnShowErrorMessage('', err);
					return false;
				}
				EsCon.set_mandatory($('#nomedit_timeslot #aviso_time_timeslot.mandatory'));
			} // success
		});
	});

	$('#save_button_timeslot').click (function () {
		if (!EsCon.check_mandatory($('#nomedit_timeslot .mandatory'))) return false;

		$('#aviso_edit #aviso_date_timeslot').val(EsCon.formatDate($('#nomedit_timeslot #aviso_date_timeslot').val()));
		$('#aviso_edit #aviso_time_timeslot').val($('#nomedit_timeslot #aviso_time_timeslot').val());
		($.magnificPopup.instance).close();

		waitingDialog();
		/*{*
		jQuery.post('/aviso/aviso_save/{$data.id}', EsCon.serialize($('#aviso_edit :input').not('#table_line :input')), function (result) {
			if (!Number(result)) {
				closeWaitingDialog();
				fnShowErrorMessage('', result);
			}
			else {
				clickOpenFile('/aviso/aviso_display/'+result+'/MP_Aviso_'+result+'.pdf');
				window.location.href = callback_url;
			}
		});
		*}*/
		$.ajax({
			type: 'POST',
			async: false,
			url: '/aviso/aviso_save/{$data.id}',
			data: EsCon.serialize($('#aviso_edit :input').not('#table_line :input')),
			success: function (result) {
				if (!Number(result)) {
					closeWaitingDialog();
					fnShowErrorMessage('', result);
				}
				else {
					clickOpenFile('/aviso/aviso_display/'+result+'/MP_Aviso_'+result+'.pdf');
					window.location.href = callback_url;
				}
			},
		});
		
	});
	$('#cancel_button_timeslot', '#nomedit_timeslot').click (function () {
		($.magnificPopup.instance).close();
	});
</script>