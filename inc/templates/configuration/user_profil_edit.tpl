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
			<div class="table-cell-label">{#table_org#}</div>
			<div class="table-cell">
				<input class="text readonly" type="text" value="{$data.org_name}" readonly>
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#org_id#}</div>
			<div class="table-cell">
				<input class="text10 readonly" type="text" value="{$data.org_id}" readonly>
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

		<input type="hidden" name="email_sended" value="{$data.email_sended}">
		<input type="hidden" name="is_active" value="{$data.is_active}">
		<input type="hidden" name="user_profil_edit" value="1">

	</div>

	{include file='configuration/btn_save_delete.tpl'}
</div>

<script type="text/javascript">
	edit_row = null;
	edit_id = 0;
	
	// Проверка дали няма въведен вече такъв потребител
	$('#user_name', '#nomedit').change(function () {
		var org_id = {$data.org_id|default:0};
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
					var html = generate_select_option_2D(data, 0);
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
</script>