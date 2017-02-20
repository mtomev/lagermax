<div id="nomedit" class="white-popup-block">
	<div class="header">
	{if $data.id > 0}{#Edit#}{else}{#Add#}{/if} {#table_shop#}
	</div>

	<div id="edit" class="nomedit-edit">
		<div class="table-row">
			<div class="table-cell-label">{#shop_name#}</div>
			<div class="table-cell">
				<input id="shop_name" class="text mandatory" type="text" maxlength="{$data.field_width.shop_name}" name="shop_name" value="{$data.shop_name}">
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#address#}</div>
			<div class="table-cell">
				<textarea id="shop_address" class="textarea" maxlength="{$data.field_width.shop_address}" name="shop_address">{$data.shop_address}</textarea>
			</div>
		</div>

		<div class="table-row">
			<div class="table-cell-label">{#shop_code#}</div>
			<div class="table-cell">
				<input id="shop_code" class="text" type="text" maxlength="{$data.field_width.shop_code}" name="shop_code" value="{$data.shop_code}">
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
