<div id="aviso_receipt" class="white-popup-block">

	<div class="header">
		<span>{#menu_aviso_reception#}</span>
	</div>

	<div class="nomedit-edit">
		<div class="table-row">
			<div class="table-cell-label">{#table_aviso#}</div>
			<div class="table-cell">
				<input type="hidden" name="aviso_id" value="{$data.aviso_id}">
				<input id="aviso_id" class="text mandatory" type="text" value="{$data.aviso_id}">
			</div>
		</div>

		<div class="table-row">
			<div class="table-cell-label">{#org_name#}</div>
			<div class="table-cell">
				<input id="org_name" class="text readonly" readonly type="text" value="{$data.org_name}">
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#warehouse_name#}</div>
			<div class="table-cell">
				<input id="warehouse_name" class="text readonly" readonly type="text" value="{$data.warehouse_name}">
			</div>
		</div>

		<div class="table-row">
			<div class="table-cell-label">{#aviso_date#}</div>
			<div class="table-cell">
				<input id="aviso_date" class="date readonly" data-type="Date" type="text" value="{$data.aviso_date}" readonly>
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#aviso_time#}</div>
			<div class="table-cell">
				<input id="aviso_time" class="time readonly" data-type="Time" type="text" value="{$data.aviso_time}" readonly>
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#note#}</div>
			<div class="table-cell">
				<textarea id="aviso_reject_reason" class="textarea" maxlength="{$data.field_width.aviso_reject_reason}" name="aviso_reject_reason">{$data.aviso_reject_reason}</textarea>
			</div>
		</div>


		<div class="table-row">
			<div class="table-cell-label">{#aviso_status#}</div>
			<div class="table-cell">
				<input type="hidden" name="aviso_status_old" value="{$data.aviso_status_old}">
				<input id="aviso_status_old" class="text10 readonly" type="text" value="{$data.aviso_status_old}" readonly>
				&nbsp;-->&nbsp;
				<select id="aviso_status" name="aviso_status" class="text10"> 
					{html_options options=$select_aviso_status selected=$data.aviso_status}
				</select>
			</div>
		</div>
	</div>

	<div class="row-button">
		<button class="save_button" id="save_button_receipt"><span>{#btn_Save#}</span></button>
		<button class="cancel_button" id="cancel_button_receipt"><span>{#btn_Cancel#}</span></button>
	</div>

</div>

<script type="text/javascript">
	var callback_url = "{$callback_url}" || document.referer;

	$('#aviso_id', '#aviso_receipt').change(function () {
		var aviso_id = Number(EsCon.getParsedVal($('#aviso_id', '#aviso_receipt')));
		if (!aviso_id) aviso_id = -1;
		$.ajax({
			url: "/configuration/list_refresh/aviso/"+aviso_id,
			method: "POST",
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
					$('[name=aviso_id]', '#aviso_receipt').val(data.aviso_id);
					$('#org_name', '#aviso_receipt').val(data.org_name);
					$('#warehouse_name', '#aviso_receipt').val(data.warehouse_name);
					$('#aviso_date', '#aviso_receipt').val(EsCon.formatDate(data.aviso_date));
					$('#aviso_time', '#aviso_receipt').val(EsCon.formatTime(data.aviso_time));
					$('#aviso_status_old', '#aviso_receipt').val(aviso_status(data.aviso_status));
					$('[name=aviso_status_old]', '#aviso_receipt').val(data.aviso_status);
					$('#aviso_reject_reason', '#aviso_receipt').html(data.aviso_reject_reason);
					// 0-заявено --> 3-прието
					if (data.aviso_status == '0')
						$('#aviso_status', '#aviso_receipt').val('3');
					else
					//  3-прието --> 0-заявено
					if (data.aviso_status == '3')
						$('#aviso_status', '#aviso_receipt').val('0');
					else
						$('#aviso_status', '#aviso_receipt').val(data.aviso_status);
				}
				catch(err) {
					console.log(result);
					fnShowErrorMessage('', err);
					return false;
				}
			} // success
		});
	});


	$(document).ready( function () {
		EsCon.set_mandatory($('#aviso_receipt .mandatory'));
		
		/*{if $data.aviso_id}*/
		$('#aviso_id', '#aviso_receipt').val({$data.aviso_id});
		$('#aviso_id', '#aviso_receipt').trigger("change");
		/*{/if}*/
	});

	$('#save_button_receipt').click (function () {
		var aviso_id = Number(EsCon.getParsedVal($('[name=aviso_id]', '#aviso_receipt')));
		if (!aviso_id) return;
		if (!checkRequired($("#aviso_status", '#aviso_receipt'), '{#aviso_status#}'))
			return false;

		waitingDialog();
		$.ajax({
			type: 'POST',
			async: false,
			url: '/aviso/aviso_save_receipt/'+aviso_id,
			data: EsCon.serialize($('#aviso_receipt :input')),
			success: function (result) {
				if (!Number(result)) {
					closeWaitingDialog();
					fnShowErrorMessage('', result);
				}
				else {
					//window.location.href = callback_url;
					edit_id = aviso_id;
					if (typeof(fancyboxSaved) == 'function') fancyboxSaved();
					closeWaitingDialog();
					($.magnificPopup.instance).close();
				}
			},
		});
		
	});
	$('#cancel_button_receipt', '#aviso_receipt').click (function () {
		($.magnificPopup.instance).close();
	});
</script>