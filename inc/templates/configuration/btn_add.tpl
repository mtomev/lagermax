{if $allow_edit}
		<span class="">&nbsp;&nbsp;</span>
		{assign var="title" value="table_{$smarty.session.table_edit}"}
		{* Когато се вика не от номенклатура, то преди това трябва да се даде стойност на $edit_url *}
		{if !isset($edit_url)}
		{assign var="edit_url" value="/configuration/{$smarty.session.table_edit}_edit/0"}
		{/if}
		<button class="add_button" href="{$edit_url}" rel="edit-0" edit_add_new="{$smarty.session.table_edit}" title="{#Add#} {$smarty.config.$title}"><span>{#add#}</span></button>
{/if}