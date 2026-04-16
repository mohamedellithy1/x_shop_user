import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/message_model.dart';
import 'package:stackfood_multivendor/features/chat/enums/user_type_enum.dart';
import 'package:stackfood_multivendor/features/chat/widgets/image_file_view_widget.dart';
import 'package:stackfood_multivendor/features/chat/widgets/pdf_view_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/localization/localization_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message currentMessage;
  final Message? previousMessage;
  final Message? nextMessage;
  final User? user;
  final UserType userType;
  const MessageBubbleWidget(
      {super.key,
      required this.currentMessage,
      required this.user,
      required this.userType,
      required this.previousMessage,
      required this.nextMessage});

  @override
  Widget build(BuildContext context) {
    bool isRightMessage = currentMessage.senderId ==
        Get.find<MarketProfileController>().userInfoModel!.userInfo!.id;
    bool isLTR = Get.find<LocalizationController>(tag: 'xmarket').isLtr;

    return GetBuilder<MarketThemeController>(
        init: Get.find<MarketThemeController>(tag: 'xmarket'),
        builder: (marketThemeController) {
          return GetBuilder<ChatController>(builder: (chatController) {
            String chatTime = chatController.getChatTime(
                currentMessage.createdAt!, nextMessage?.createdAt);
            String previousMessageHasChatTime = previousMessage != null
                ? chatController.getChatTime(
                    previousMessage!.createdAt!, currentMessage.createdAt)
                : "";
            bool isSameUserWithPreviousMessage =
                _isSameUserWithPreviousMessage(previousMessage, currentMessage);
            bool isSameUserWithNextMessage =
                _isSameUserWithNextMessage(currentMessage, nextMessage);
            bool canShowSeenIcon = isRightMessage &&
                currentMessage.isSeen == 0 &&
                currentMessage.filesFullUrl!.isEmpty;
            bool canShowImageSeenIcon = isRightMessage &&
                currentMessage.isSeen == 0 &&
                currentMessage.filesFullUrl!.isNotEmpty;

            return Column(
                crossAxisAlignment: isRightMessage
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (chatTime != "")
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeExtraSmall, top: 5),
                        child: Text(
                          chatController.getChatTime(currentMessage.createdAt!,
                              nextMessage?.createdAt),
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeExtraSmall),
                        ),
                      ),
                    ),
                  Padding(
                    padding: isRightMessage
                        ? EdgeInsets.fromLTRB(
                            20,
                            isSameUserWithNextMessage ? 3 : 10,
                            Dimensions.paddingSizeSmall,
                            (isSameUserWithNextMessage ||
                                    isSameUserWithPreviousMessage)
                                ? 3
                                : 10)
                        : EdgeInsets.fromLTRB(
                            Dimensions.paddingSizeSmall,
                            isSameUserWithNextMessage ? 3 : 10,
                            20,
                            (isSameUserWithNextMessage ||
                                    isSameUserWithPreviousMessage)
                                ? 3
                                : 10),
                    child: Column(
                        crossAxisAlignment: isRightMessage
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: isRightMessage
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                isRightMessage
                                    ? const SizedBox()
                                    : (!isRightMessage &&
                                                !isSameUserWithPreviousMessage) ||
                                            ((!isRightMessage &&
                                                    isSameUserWithPreviousMessage) &&
                                                chatController
                                                    .getChatTimeWithPrevious(
                                                        currentMessage,
                                                        previousMessage)
                                                    .isNotEmpty)
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions
                                                        .paddingSizeExtraLarge *
                                                    2),
                                            child: CustomImageWidget(
                                              fit: BoxFit.cover,
                                              width: 32,
                                              height: 32,
                                              image: '${user!.imageFullUrl}',
                                            ),
                                          )
                                        : !isRightMessage
                                            ? const SizedBox(
                                                width: 15 +
                                                    Dimensions
                                                        .paddingSizeExtraSmall)
                                            : const SizedBox(),
                                const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall),
                                Flexible(
                                  child: Column(
                                      crossAxisAlignment: isRightMessage
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (currentMessage.message != null)
                                          Flexible(
                                              child: Container(
                                            decoration: BoxDecoration(
                                              color: isRightMessage
                                                  ? Theme.of(context).primaryColor
                                                  : (marketThemeController.darkTheme
                                                      ? const Color(0xFF1b1b1b)
                                                      : Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                                              borderRadius: isRightMessage &&
                                                      (isSameUserWithNextMessage ||
                                                          isSameUserWithPreviousMessage)
                                                  ? BorderRadius.only(
                                                      topRight: Radius.circular(
                                                          isSameUserWithNextMessage &&
                                                                  isLTR &&
                                                                  chatTime == ""
                                                              ? Dimensions
                                                                  .radiusSmall
                                                              : Dimensions
                                                                      .radiusExtraLarge +
                                                                  5),
                                                      bottomRight: Radius.circular(
                                                          isSameUserWithPreviousMessage &&
                                                                  isLTR &&
                                                                  previousMessageHasChatTime ==
                                                                      ""
                                                              ? Dimensions
                                                                  .radiusSmall
                                                              : Dimensions
                                                                      .radiusExtraLarge +
                                                                  5),
                                                      topLeft: Radius.circular(
                                                          isSameUserWithNextMessage &&
                                                                  !isLTR &&
                                                                  chatTime == ""
                                                              ? Dimensions
                                                                  .radiusSmall
                                                              : Dimensions
                                                                      .radiusExtraLarge +
                                                                  5),
                                                      bottomLeft: Radius.circular(
                                                          isSameUserWithPreviousMessage &&
                                                                  !isLTR &&
                                                                  previousMessageHasChatTime ==
                                                                      ""
                                                              ? Dimensions
                                                                  .radiusSmall
                                                              : Dimensions
                                                                  .radiusExtraLarge),
                                                    )
                                                  : !isRightMessage &&
                                                          (isSameUserWithNextMessage ||
                                                              isSameUserWithPreviousMessage)
                                                      ? BorderRadius.only(
                                                          topLeft: Radius.circular(
                                                              isSameUserWithNextMessage &&
                                                                      isLTR &&
                                                                      chatTime ==
                                                                          ""
                                                                  ? Dimensions
                                                                      .radiusSmall
                                                                  : Dimensions
                                                                          .radiusExtraLarge +
                                                                      5),
                                                          bottomLeft: Radius.circular(
                                                              isSameUserWithPreviousMessage &&
                                                                      isLTR &&
                                                                      previousMessageHasChatTime ==
                                                                          ""
                                                                  ? Dimensions
                                                                      .radiusSmall
                                                                  : Dimensions
                                                                          .radiusExtraLarge +
                                                                      5),
                                                          topRight: Radius.circular(
                                                              isSameUserWithNextMessage &&
                                                                      !isLTR &&
                                                                      chatTime ==
                                                                          ""
                                                                  ? Dimensions
                                                                      .radiusSmall
                                                                  : Dimensions
                                                                          .radiusExtraLarge +
                                                                      5),
                                                          bottomRight: Radius.circular(
                                                              isSameUserWithPreviousMessage &&
                                                                      !isLTR &&
                                                                      previousMessageHasChatTime ==
                                                                          ""
                                                                  ? Dimensions
                                                                      .radiusSmall
                                                                  : Dimensions
                                                                          .radiusExtraLarge +
                                                                      5),
                                                        )
                                                      : BorderRadius.circular(
                                                          Dimensions
                                                                  .radiusExtraLarge +
                                                              5),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            margin: EdgeInsets.only(
                                                left: isRightMessage
                                                    ? context.width * 0.1
                                                    : 0,
                                                right: isRightMessage
                                                    ? 0
                                                    : context.width * 0.1),
                                            child: InkWell(
                                              onTap: () {
                                                chatController
                                                    .toggleOnClickMessage(
                                                        currentMessage.id!);
                                              },
                                              child: Text(
                                                currentMessage.message ?? '',
                                                style: robotoRegular.copyWith(
                                                  color: isRightMessage
                                                      ? Colors.white
                                                      : (marketThemeController
                                                              .darkTheme
                                                          ? Colors.white
                                                          : Color(0xFF55745a)),
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                ),
                                              ),
                                            ),
                                          )),
                                        Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AnimatedContainer(
                                                curve: Curves.fastOutSlowIn,
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                height: chatController
                                                            .onMessageTimeShowID ==
                                                        currentMessage.id
                                                    ? 25.0
                                                    : 0.0,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    top: chatController
                                                                .onMessageTimeShowID ==
                                                            currentMessage.id
                                                        ? Dimensions
                                                            .paddingSizeExtraSmall
                                                        : 0.0,
                                                  ),
                                                  child: Text(
                                                    chatController
                                                            .getOnPressChatTime(
                                                                currentMessage) ??
                                                        "",
                                                    style: robotoRegular.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall,
                                                        color:
                                                            marketThemeController
                                                                    .darkTheme
                                                                ? Colors.white70
                                                                : Color(0xFF55745a)),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall),
                                              canShowSeenIcon
                                                  ? Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Icon(
                                                        currentMessage.isSeen ==
                                                                1
                                                            ? Icons.done_all
                                                            : Icons.check,
                                                        size: 12,
                                                        color: currentMessage
                                                                    .isSeen ==
                                                                1
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Theme.of(context)
                                                                .disabledColor,
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ]),
                                        if (currentMessage.filesFullUrl !=
                                                null &&
                                            currentMessage
                                                .filesFullUrl!.isNotEmpty)
                                          const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeSmall),
                                        currentMessage.filesFullUrl!.isNotEmpty
                                            ? Column(
                                                crossAxisAlignment:
                                                    isRightMessage
                                                        ? CrossAxisAlignment.end
                                                        : CrossAxisAlignment
                                                            .start,
                                                children: [
                                                    currentMessage.filesFullUrl!
                                                            .isNotEmpty
                                                        ? Directionality(
                                                            textDirection: isRightMessage &&
                                                                    isLTR
                                                                ? TextDirection
                                                                    .rtl
                                                                : !isLTR &&
                                                                        !isRightMessage
                                                                    ? TextDirection
                                                                        .rtl
                                                                    : TextDirection
                                                                        .ltr,
                                                            child: SizedBox(
                                                              width: ResponsiveHelper
                                                                      .isDesktop(
                                                                          context)
                                                                  ? _isPdf(currentMessage
                                                                              .filesFullUrl![
                                                                          0])
                                                                      ? 200
                                                                      : 400
                                                                  : _isPdf(currentMessage
                                                                          .filesFullUrl![0])
                                                                      ? 200
                                                                      : 150,
                                                              child: _isPdf(
                                                                      currentMessage
                                                                              .filesFullUrl![
                                                                          0])
                                                                  ? PdfViewWidget(
                                                                      currentMessage:
                                                                          currentMessage,
                                                                      isRightMessage:
                                                                          isRightMessage)
                                                                  : ImageFileViewWidget(
                                                                      currentMessage:
                                                                          currentMessage,
                                                                      isRightMessage:
                                                                          isRightMessage),
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                    Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          AnimatedContainer(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                top: Dimensions
                                                                    .paddingSizeExtraSmall),
                                                            curve: Curves
                                                                .fastOutSlowIn,
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        500),
                                                            height: chatController
                                                                        .onImageOrFileTimeShowID ==
                                                                    currentMessage
                                                                        .id
                                                                ? 25.0
                                                                : 0.0,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                top: chatController
                                                                            .onMessageTimeShowID ==
                                                                        currentMessage
                                                                            .id
                                                                    ? Dimensions
                                                                        .paddingSizeExtraSmall
                                                                    : 0.0,
                                                              ),
                                                              child: Text(
                                                                chatController
                                                                        .getOnPressChatTime(
                                                                            currentMessage) ??
                                                                    "",
                                                                style: robotoRegular.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall,
                                                                    color: marketThemeController.darkTheme
                                                                        ? Colors
                                                                            .white70
                                                                        : Color(0xFF55745a)
                                                                            ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          canShowImageSeenIcon
                                                              ? Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  child: Icon(
                                                                    currentMessage.isSeen ==
                                                                            1
                                                                        ? Icons
                                                                            .done_all
                                                                        : Icons
                                                                            .check,
                                                                    size: 12,
                                                                    color: currentMessage.isSeen ==
                                                                            1
                                                                        ? Theme.of(context)
                                                                            .primaryColor
                                                                        : Theme.of(context)
                                                                            .disabledColor,
                                                                  ),
                                                                )
                                                              : const SizedBox(),
                                                        ]),
                                                  ])
                                            : const SizedBox.shrink(),
                                      ]),
                                )
                              ]),
                        ]),
                  ),
                ]);
          });
        });
  }

  bool _isSameUserWithPreviousMessage(
      Message? previousConversation, Message? currentConversation) {
    if (previousConversation?.senderId == currentConversation?.senderId &&
        previousConversation?.message != null &&
        currentConversation?.message != null) {
      return true;
    }
    return false;
  }

  bool _isSameUserWithNextMessage(
      Message? currentConversation, Message? nextConversation) {
    if (currentConversation?.senderId == nextConversation?.senderId &&
        nextConversation?.message != null &&
        currentConversation?.message != null) {
      return true;
    }
    return false;
  }

  bool _isPdf(String url) {
    if (url.contains('.pdf')) {
      return true;
    }
    return false;
  }
}
