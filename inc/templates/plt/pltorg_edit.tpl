{$dont_include_lang=true}
{extends file="layout.tpl"}
{block name=content}
<div id="main" {*class="mfp-inline-holder"*}>
	<div id="doc_edit" class="white-popup-block">
		<div class="header">{#table_pltorg#}</div>

		<div class="nomedit-edit">
			<div style="display: table;">
				<div style="float: left;">
					<div class="table-row">
						<div class="table-cell-label">{#pltorg_date#}</div>
						<div class="table-cell">
							{if !$data.aviso_id}
							<input class="date mandatory" data-type="Date" type="text" name="pltorg_date" value="{$data.pltorg_date}">
							{else}
							<input class="date readonly" data-type="Date" type="text" value="{$data.pltorg_date}" readonly>
							{/if}
						</div>
						{if $data.aviso_id}
						<span class="" style="padding-left: 10px;">
							{#aviso_id#}
							<input class="text10 readonly" readonly type="text" name="aviso_id" value="{$data.aviso_id}">
						</span>
						{/if}
					</div>

					<div class="table-row">
						<div class="table-cell-label">{#org_name#}</div>
						<div class="table-cell">
							{if !$data.aviso_id}
							<select class="text mandatory select2chosen" name="org_id" data-width="340px;">
								{html_options options=$select_org selected={$data.org_id}}
							</select>
							{else}
							<input class="text readonly" readonly type="text" value="{$data.org_name}">
							{/if}
						</div>
					</div>

					<div class="table-row">
						<div class="table-cell-label">{#pltorg_refnumb#}</div>
						<div class="table-cell">
							<input class="text" type="text" value="{$data.pltorg_refnumb}">
						</div>
					</div>
					<div class="table-row">
						<div class="table-cell-label">{#pltorg_driver#}</div>
						<div class="table-cell">
							<input class="text" type="text" value="{$data.pltorg_driver}">
						</div>
					</div>
				</div>

			</div>
			<hr>



			{* Амбалаж *}
			<div style="display: table; clear: left;">
				<div style="float: left;">
					<div class="table-row">
						<div class="table-cell-label">{#qty_plt_eur#}</div>
						<div class="table-cell">
							<input class="number-small" data-type="Number0" type="text" name="qty_plt_eur" value="{$data.qty_plt_eur}">
						</div>
					</div>
					<div class="table-row">
						<div class="table-cell-label">{#qty_plt_chep#}</div>
						<div class="table-cell">
							<input class="number-small" data-type="Number0" type="text" name="qty_plt_chep" value="{$data.qty_plt_chep}">
						</div>
					</div>
					<div class="table-row">
						<div class="table-cell-label">{#qty_plt_other#}</div>
						<div class="table-cell">
							<input class="number-small" data-type="Number0" type="text" name="qty_plt_other" value="{$data.qty_plt_other}">
						</div>
					</div>
				</div>
				<div style="float: left; padding-left: 40px;">
					<div class="table-row">
						<div class="table-cell-label">{#qty_ret_plt_eur#}</div>
						<div class="table-cell">
							<input class="number-small" data-type="Number0" type="text" name="qty_ret_plt_eur" value="{$data.qty_ret_plt_eur}">
						</div>
					</div>
					<div class="table-row">
						<div class="table-cell-label">{#qty_ret_plt_chep#}</div>
						<div class="table-cell">
							<input class="number-small" data-type="Number0" type="text" name="qty_ret_plt_chep" value="{$data.qty_ret_plt_chep}">
						</div>
					</div>
					<div class="table-row">
						<div class="table-cell-label">{#qty_ret_plt_other#}</div>
						<div class="table-cell">
							<input class="number-small" data-type="Number0" type="text" name="qty_ret_plt_other" value="{$data.qty_ret_plt_other}">
						</div>
					</div>
				</div>
				<div style="float: left; padding-left: 40px;">
					<div class="table-row">
						<div class="table-cell-label">{#qty_claim_plt_eur#}</div>
						<div class="table-cell">
							<input class="number-small" data-type="Number0" type="text" name="qty_claim_plt_eur" value="{$data.qty_claim_plt_eur}">
						</div>
					</div>
					<div class="table-row">
						<div class="table-cell-label">{#qty_claim_plt_chep#}</div>
						<div class="table-cell">
							<input class="number-small" data-type="Number0" type="text" name="qty_claim_plt_chep" value="{$data.qty_claim_plt_chep}">
						</div>
					</div>
					<div class="table-row">
						<div class="table-cell-label">{#qty_claim_plt_other#}</div>
						<div class="table-cell">
							<input class="number-small" data-type="Number0" type="text" name="qty_claim_plt_other" value="{$data.qty_claim_plt_other}">
						</div>
					</div>
				</div>
			</div>
			<hr>

			<div style="display: table; clear: left;">
				<div class="table-cell-label">{#note#}</div>
				<div class="table-cell">
					<textarea class="textarea" maxlength="{$data.field_width.pltorg_note}" name="pltorg_note">{$data.pltorg_note}</textarea>
				</div>
			</div>
			<hr>
		</div>


		<div class="row-button">
		{if $data.allow_edit}
			<button class="save_button" id="save_button_doc"><span>{#btn_Save#}</span></button>
		{/if}
			<span>id:{$data.id}</span>
			<button class="cancel_button" id="cancel_button_doc"><span>{#btn_Cancel#}</span></button>
			<button class="save_button" id="print_button_doc" style="margin-left: 40px;"><span>{#btn_Print_ppp#}</span></button>
		</div>
		{include file='main_menu/status_line.tpl'}
	</div>
</div>

<script type="text/javascript">
	var callback_url = "{$callback_url}" || document.referer;

	$(document).ready( function () {
	// Група от общи
		$("select.select2chosen:not(.hasChosen)", '#doc_edit').each(function (idx, el) {
			select2chosen(el);
		});

		EsCon.set_datepicker('input.date, input.datetime', '#doc_edit');
		// Това се прилага само за показаните със smarty променливи стойности в #doc_edit, но не и за показаните с рендер функции в таблиците
		EsCon.set_number_val($('.number, .number-small, .time', '#doc_edit'));
		// Да сложим attr placeholder на всички с .mandatory
		EsCon.set_mandatory($('#doc_edit .mandatory'));

		// Ще ги задам така, защото по-късно динамично се добавят DOM елементи от същия вид
		$('#doc_edit').on('focus', '.number, .number-small, .date, .time', EsCon.inputEvent.focusin);
		$('#doc_edit').on('change', '.number, .number-small, .date, .time', EsCon.inputEvent.change);
		$('#doc_edit').on('keydown', '.number, .number-small', EsCon.inputEvent.keydown);

	// край на Група от общи

	});

	$('#print_button_doc', '#doc_edit').click (function () {
		clickOpenFile('/plt/pltorg_display/{$data.id}/{$data.scan_doc}');
	});

	$('#save_button_doc', '#doc_edit').click (function () {
		if (!EsCon.check_mandatory($('#doc_edit .mandatory'))) return false;

		waitingDialog();
		$.ajax({
			type: 'POST',
			async: false,
			url: '/plt/pltorg_save/{$data.id}',
			data: EsCon.serialize($('#doc_edit :input')),
			success: function (result) {
				if (!Number(result)) {
					closeWaitingDialog();
					fnShowErrorMessage('', result);
				}
				else {
					//clickOpenFile('/plt/pltorg_display/'+result+'/{$data.scan_doc}');
					window.location.href = callback_url;
				}
			},
		});
	});

	$('#cancel_button_doc', '#doc_edit').click (function () {
		window.location.href = callback_url;
	});
</script>
{/block}
