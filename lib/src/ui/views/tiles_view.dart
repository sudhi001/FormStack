import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/step/display_step.dart';

class ListTitlesView {
  static Widget buildView(BuildContext context, DisplayStep formStep) {
    return Container(
        decoration: formStep.componentsStyle == ComponentsStyle.minimal
            ? const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey),
                ),
              )
            : null,
        constraints: const BoxConstraints(maxWidth: 300.0),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          separatorBuilder: (context, index) => Divider(
              color: formStep.componentsStyle == ComponentsStyle.minimal
                  ? Colors.grey
                  : CupertinoColors.white,
              height: 5),
          itemBuilder: (context, index) {
            final DynamicData dynamicData = formStep.data[index];
            return _buildListTile(context, dynamicData, formStep);
          },
          itemCount: formStep.data.length,
        ));
  }

  static Widget _buildListTile(
      BuildContext context, DynamicData dynamicData, DisplayStep formStep) {
    final bool isBasicStyle = formStep.componentsStyle == ComponentsStyle.basic;

    return ClipRRect(
        borderRadius: isBasicStyle
            ? const BorderRadius.vertical(
                top: Radius.circular(12),
                bottom: Radius.circular(12),
              )
            : const BorderRadius.vertical(),
        child: Container(
          color: isBasicStyle ? const Color.fromRGBO(242, 242, 247, 1) : null,
          padding: const EdgeInsets.all(7),
          child: ListTile(
              title: Text(dynamicData.title,
                  style: Theme.of(context).textTheme.bodyMedium),
              subtitle: dynamicData.subTitle != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(dynamicData.subTitle!,
                          style: Theme.of(context).textTheme.bodySmall),
                    )
                  : null,
              leading: dynamicData.leading != null
                  ? Text(dynamicData.leading!,
                      style: Theme.of(context).textTheme.headlineLarge)
                  : null,
              trailing: dynamicData.trailing != null
                  ? Text(dynamicData.trailing!,
                      style: Theme.of(context).textTheme.bodySmall)
                  : null),
        ));
  }
}
