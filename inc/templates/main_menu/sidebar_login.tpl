<style>
	body {
		margin-left: 0px !important;
	}
	form > div {
		float: left; clear: left; margin-left:15px; margin-top:10px; margin-right:10px;
	}
	form > div > label {
		float: left; width: 120px; text-align: right; padding-right: 10px;
	}
</style>
<div style="margin: auto; width: 350px; padding: 15% 0px;">
	<form action="" method="post" style="border: 1px solid #A6C9E2; display:inline-block;" id="id-login">
		<h3 style="text-align: center; padding-left: 0px;">{#site_title#}</h3>
		<br>

		<div>
			<label for="org_id">{#org_id#}</label>
		{if !$smarty.session.org_id}
			<input type="text" name="org_id" id="org_id" value="{$smarty.session.org_id}" style="float: left; width:150px;">
		{else}
			<input type="text" name="org_id" id="org_id" class="readonly" value="{$smarty.session.org_id}" style="float: left; width:150px; background-color: #F0F0F0;" readonly>
		{/if}
		</div>
		<div>
			<label for="username">{#login_name#}</label>
			<input type="text" name="username" id="username" value="" style="float: left; width:150px;">
		</div>
		<div>
			<label for="password" >{#login_pass#}</label>
			<input type="password" name="password" id="password" value="" style="float: left; width:150px;">
		</div>

		<div>
			 <span id="display_text" class="hidden" style="float:left;">{#wrong_login#}</span>
		</div>

		<div style="float: left; clear: left; margin-left: 15px; margin-top: 10px; margin-bottom:10px;">
			<button class="save_button" id="login_button"><span>{#btn_login#}</span></button>
			{include file='main_menu/sidebar_lang.tpl'}
			<button class="delete_button" id="mail_button" title="{#btn_forgotten_title#}"><span>{#btn_forgotten#}</span></button>
		</div>
	</form>
</div>

<script type="text/javascript">
	document.getElementById("id-login").onkeydown = function(event) {
		if (event.keyCode == 13)
			$('#login_button').trigger('click');
	};
	$('#login_button').click (function () {
		waitingDialog();
		jQuery.post('/main_menu/login', { 'org_id': $('#org_id').val(), 'login_user': $('#username').val(), 'login_pass': $('#password').val() }, function (result) {
			if (parseInt(result) == 1) {
				$('#id-login').submit();
				window.location.href = '{$smarty.session.relogin_url}';
			} else {
				closeWaitingDialog();
				if (parseInt(result) === 0)
					$('#display_text').removeClass("hidden");
				else {
					$('#display_text').addClass("hidden");
					if (result)
						fnShowErrorMessage('', result);
				}
			}
		});

		return false;
	});
	$('#mail_button').click (function () {
		waitingDialog();
		jQuery.post('/main_menu/mail_password', { 'org_id': $('#org_id').val(), 'login_user': $('#username').val(), 'login_pass': $('#password').val() }, function (result) {
			closeWaitingDialog();
			// При успешен mail, връщаме 1
			if (parseInt(result) == 1) {
				fnShowInfoMessage('', 'Изпратен е мейл на посочения в профила e-mail адрес');
			} else {
				if (result)
					fnShowErrorMessage('', result);
			}
		});

		return false;
	});

</script>
