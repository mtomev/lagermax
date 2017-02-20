<div id="nomedit" class="white-popup-block">
	<div class="header">
	{if $data.id > 0}{#Edit#}{else}{#Add#}{/if} {#table_config#}
	</div>

	<div id="edit" class="nomedit-edit">
		<div class="table-row">
			<div class="table-cell-label">{#name#}</div>
			<div class="table-cell">
				<input id="config_name" class="text mandatory" type="text" maxlength="{$data.field_width.config_name}" name="config_name" value="{$data.config_name}">
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#config_value#}</div>
			<div class="table-cell">
				<textarea id="config_value" class="textarea" name="config_value">{$data.config_value}</textarea>
			</div>
		</div>

	</div>

	{include file='configuration/btn_save_delete.tpl'}
</div>

<script type="text/javascript">
</script>