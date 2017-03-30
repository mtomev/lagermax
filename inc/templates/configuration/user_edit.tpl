<div id="nomedit" class="white-popup-block">
	<div class="header">
	{if $data.id > 0}{#Edit#}{else}{#Add#}{/if} {#table_user#}
	</div>

	<div id="edit" class="nomedit-edit">
		<div class="table-row">
			<div class="table-cell-label">{#name#}</div>
			<div class="table-cell">
				<input id="user_name" class="text mandatory" type="text" maxlength="{$data.field_width.user_name}" name="user_name" value="{$data.user_name}">
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#user_password#}</div>
			<div class="table-cell">
				<input id="user_password" class="text30 mandatory" type="text" maxlength="{$data.field_width.user_password}" name="user_password" value="{$data.user_password}">
				<button class="submit_button" id="gen_password" title="{#btn_gen_password_title#}"><span>{#btn_gen_password#}</span></button>
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#user_role_name#}</div>
			<div class="table-cell">
				<select id="user_role_id" name="user_role_id" class="text30 mandatory"> 
					{html_options options=$select_user_role selected=$data.user_role_id}
				</select>
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#table_org#}</div>
			<div class="table-cell">
				<select id="org_id" name="org_id" class="text select2chosen" data-width="340px;"> 
					{html_options options=$select_org selected=$data.org_id}
				</select>
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#org_id#}</div>
			<div class="table-cell">
				<input id="org_id_text" class="text10 readonly" type="text" value="{$data.org_id}" readonly>
			</div>
		</div>

		<div class="table-row">
			<div class="table-cell-label">{#full_name#}</div>
			<div class="table-cell">
				<input id="user_full_name" class="text" type="text" maxlength="{$data.field_width.user_full_name}" name="user_full_name" value="{$data.user_full_name}">
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#phone#}</div>
			<div class="table-cell">
				<input id="user_phone" class="text" type="text" maxlength="{$data.field_width.user_phone}" name="user_phone" value="{$data.user_phone}">
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#email#}</div>
			<div class="table-cell">
				<input id="user_email" class="text" type="text" maxlength="{$data.field_width.user_email}" name="user_email" value="{$data.user_email}">
			</div>
		</div>

		<hr>
		<div class="table-row">
			<div class="table-cell-label"></div>
			<div class="table-cell">
				Подразбиращи се стойности при ново Авизо
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#w_group_name#}</div>
			<div class="table-cell">
				<select id="w_group_id" name="w_group_id" class="text30"> 
					{html_options options=$select_w_group selected=$data.w_group_id}
				</select>
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#warehouse_name#}</div>
			<div class="table-cell">
				<select id="warehouse_id" name="warehouse_id" class="text"> 
					{html_options options=$select_warehouse selected=$data.warehouse_id}
				</select>
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#aviso_driver_name#}</div>
			<div class="table-cell">
				<input id="aviso_driver_name" class="text" type="text" maxlength="{$data.field_width.aviso_driver_name}" name="aviso_driver_name" value="{$data.aviso_driver_name}">
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#aviso_driver_phone#}</div>
			<div class="table-cell">
				<input id="aviso_driver_phone" class="text" type="text" maxlength="{$data.field_width.aviso_driver_phone}" name="aviso_driver_phone" value="{$data.aviso_driver_phone}">
			</div>
		</div>
		<hr>

		<div style="float: left;">
			<div class="table-row">
				<div class="table-cell-label"></div>
				<div class="table-cell">
					<input id="email_sended" class="" type="checkbox" name="email_sended" value="1" {if $data.email_sended == '1'}checked="checked"{/if}>&nbsp;email sended
				</div>
			</div>

			<div class="table-row">
				<div class="table-cell-label"></div>
				<div class="table-cell">
					<input id="is_active" class="" type="checkbox" name="is_active" value="1" {if $data.is_active}checked="checked"{/if}>&nbsp;{#is_active#}
				</div>
			</div>
		</div>

		<div style="float: left; margin-left:40px;">
			<div class="table-row">
				<div class="table-cell-label"></div>
				<div class="table-cell">
					<button class="submit_button" id="btn_test_email"><span>{#btn_test_email#}</span></button>
				</div>
			</div>
		</div>

	</div>

	{include file='configuration/btn_save_delete.tpl'}
</div>

<script type="text/javascript">
	$('#btn_test_email').click (function () {
		var user_email = $('#user_email', '#nomedit').val();
		if (!user_email) return false;
		saveData(false, function() {
			waitingDialog('sending to {$data.full_name} {$data.user_email}');
			if ({$data.id} > 0)
				var url = '/configuration/send_test_mail/{$data.user_id}';
			else
				var url = '/configuration/send_test_mail/-1';

			$.ajax({
				url: url,
				data: $('#edit :input').serialize(),
				dataType: 'html',
				//timeout: 5000,
				success: function (result) {
					closeWaitingDialog();
					if (result) {
						fnShowErrorMessage('', result);
						if ({$data.id} > 0)
							return false;
					}
					($.magnificPopup.instance).close();
				}
			});
		});
	});

	// Проверка дали няма въведен вече такъв потребител
	$('#org_id, #user_name', '#nomedit').change(function () {
		var org_id = $('#org_id', '#nomedit').val();
		$('#org_id_text', '#nomedit').val(org_id);
		var user_name = $('#user_name', '#nomedit').val();
		if (user_name)
			$.ajax({
				url: "/configuration/check_unique_user/{$data.id}",
				method: "POST",
				data: { org_id: org_id, user_name: user_name, user_id: {$data.id} }, 
				success: function (data) {
					if (data)
						fnShowErrorMessage('', data);
				} // success
			});
	});

	$('#user_email', '#nomedit').change(function () {
		if ($('#user_email', '#nomedit').val())
			$('#btn_test_email', '#nomedit').show();
		else
			$('#btn_test_email', '#nomedit').hide();
	});
	$('#user_email', '#nomedit').trigger('change');

	// При смяна на w_group_id, да изтегля списъка от складовете
	// w_group_id, aviso_date, aviso_time, брой палети
	$('#w_group_id', '#nomedit').change(function () {
		var w_group_id = EsCon.getParsedVal($('#w_group_id', '#nomedit'));
		$.ajax({
			url: "/aviso/get_w_group_id_warehouse/"+w_group_id,
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
					var html = generate_select_option_2D(data, 0, true);
					$('#warehouse_id', '#nomedit').empty().append(html);
				}
				catch(err) {
					console.log(result);
					fnShowErrorMessage('', err);
					return false;
				}
				EsCon.set_mandatory($('#nomedit #warehouse_id.mandatory').removeClass('hasMandatory'));
			} // success
		});
	});

	$('#gen_password').click (function () {
		$.ajax({
			url: '/configuration/ajax_gen_password',
			success: function (result) {
				$('#user_password', '#nomedit').val(result);
			}
		});
	});

	function callbackSave() {
		return true;
	}

	$("select.select2chosen:not(.hasChosen)", '#nomedit').each(function (idx, el) {
		select2chosen(el);
	});

</script>