<div id="nomedit" class="white-popup-block">
	<div class="header">
	{if $data.id > 0}{#Edit#}{else}{#Add#}{/if} {#table_w_group#}
	</div>

	<div id="edit" class="nomedit-edit">
		<div class="table-row">
			<div class="table-cell-label">{#w_group_name#}</div>
			<div class="table-cell">
				<input id="w_group_name" class="text mandatory" type="text" maxlength="{$data.field_width.w_group_name}" name="w_group_name" value="{$data.w_group_name}">
			</div>
		</div>
		
		<div class="table-row">
			<div class="table-cell-label">{#w_group_address#}</div>
			<div class="table-cell">
				<textarea id="w_group_address" class="textarea" maxlength="{$data.field_width.w_group_address}" name="w_group_address">{$data.w_group_address}</textarea>
			</div>
		</div>

		<div class="table-row">
			<div class="table-cell-label"></div>
			<div class="table-cell">
				<input id="is_active" class="" type="checkbox" name="is_active" value="1" {if $data.is_active}checked="checked"{/if}>&nbsp;{#is_active#}
			</div>
		</div>
	</div>

	{include file='configuration/btn_save_delete.tpl'}
</div>

<script type="text/javascript">
	$(document).ready( function () {
		// Автоматично разпъване на textarea
		$('textarea', '#nomedit').each(function () {
			textarea_auto_height(this);
		});
	}); // $(document).ready

	function callbackSave() {
		return true;
	}

</script>
