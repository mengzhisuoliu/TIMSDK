package com.tencent.qcloud.tuikit.tuiconversation.classicui.page;

import android.content.Intent;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.PopupWindow;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.component.action.PopActionClickListener;
import com.tencent.qcloud.tuikit.timcommon.component.action.PopDialogAdapter;
import com.tencent.qcloud.tuikit.timcommon.component.action.PopMenuAction;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.util.LayoutUtil;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationGroupBean;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.interfaces.OnConversationAdapterListener;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.util.TUIConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.widget.ConversationLayout;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.ConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.TUIConversationLog;
import com.tencent.qcloud.tuikit.tuiconversation.config.classicui.TUIConversationConfigClassic;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationPresenter;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUIConversationFragment extends Fragment {
    private static final String TAG = TUIConversationFragment.class.getSimpleName();

    private View mBaseView;
    private ConversationLayout mConversationLayout;
    private ListView mConversationPopList;
    private PopDialogAdapter mConversationPopAdapter;
    private PopupWindow mConversationPopWindow;
    private List<PopMenuAction> mConversationPopActions = new ArrayList<>();

    private ConversationPresenter presenter;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        TUIConversationLog.d(TAG, "onCreateView");
        mBaseView = inflater.inflate(R.layout.conversation_fragment, container, false);
        initView();
        return mBaseView;
    }

    @Override
    public void onResume() {
        super.onResume();
        presenter.setFocus(true);
        TUIConversationLog.d(TAG, "onResume");
    }

    @Override
    public void onPause() {
        super.onPause();
        presenter.setFocus(false);
        TUIConversationLog.d(TAG, "onPause");
    }

    public static TUIConversationFragment newInstance() {
        TUIConversationFragment fragment = new TUIConversationFragment();
        return fragment;
    }

    private void initView() {
        
        mConversationLayout = mBaseView.findViewById(R.id.conversation_layout);

        presenter = new ConversationPresenter();
        presenter.setConversationListener();
        presenter.setShowType(ConversationPresenter.SHOW_TYPE_CONVERSATION_LIST_WITH_FOLD);
        presenter.setConversationGroupType(ConversationGroupBean.CONVERSATION_GROUP_TYPE_DEFAULT);
        mConversationLayout.setPresenter(presenter);

        mConversationLayout.initDefault();

        mConversationLayout.getConversationList().setOnConversationAdapterListener(new OnConversationAdapterListener() {
            @Override
            public void onItemClick(View view, int viewType, ConversationInfo conversationInfo) {
                
                if (conversationInfo.isMarkFold()) {
                    mConversationLayout.clearUnreadStatusOfFoldItem();
                    startFoldedConversationActivity();
                } else {
                    TUIConversationUtils.startChatActivity(conversationInfo);
                }
            }

            @Override
            public void onItemLongClick(View view, ConversationInfo conversationInfo) {
                showItemPopMenu(view, conversationInfo);
            }

            @Override
            public void onConversationChanged(List<ConversationInfo> dataSource) {
                if (dataSource == null) {
                    return;
                }
                ConversationInfo conversationInfo = dataSource.get(0);
                if (conversationInfo == null) {
                    return;
                }
            }
        });

        restoreConversationItemBackground();
    }

    public void restoreConversationItemBackground() {
        if (mConversationLayout.getConversationList().getAdapter() != null && mConversationLayout.getConversationList().getAdapter().isClick()) {
            mConversationLayout.getConversationList().getAdapter().setClick(false);
            mConversationLayout.getConversationList().getAdapter().notifyItemChanged(
                mConversationLayout.getConversationList().getAdapter().getCurrentPosition());
        }
    }

    private PopMenuAction getMarkUnreadPopMenuAction(boolean markUnread) {
        PopMenuAction markUnreadAction = new PopMenuAction();
        markUnreadAction.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int index, Object data) {
                mConversationLayout.markConversationUnread((ConversationInfo) data, markUnread);
            }
        });
        if (markUnread) {
            markUnreadAction.setActionName(getResources().getString(R.string.mark_unread));
        } else {
            markUnreadAction.setActionName(getResources().getString(R.string.mark_read));
        }
        markUnreadAction.setWeight(900);
        return markUnreadAction;
    }

    private PopMenuAction getDeletePopMenuAction() {
        PopMenuAction action = new PopMenuAction();
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int index, Object data) {
                TUIKitDialog tipsDialog =
                    new TUIKitDialog(getContext())
                        .builder()
                        .setCancelable(true)
                        .setCancelOutside(true)
                        .setTitle(getContext().getString(R.string.conversation_delete_tips))
                        .setDialogWidth(0.75f)
                        .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure),
                            new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    mConversationLayout.deleteConversation((ConversationInfo) data);
                                }
                            })
                        .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {}
                        });
                tipsDialog.show();
            }
        });
        action.setActionName(getResources().getString(R.string.chat_delete));
        action.setWeight(700);
        return action;
    }

    private void showItemPopMenu(View view, final ConversationInfo conversationInfo) {
        mConversationPopActions.clear();

        PopMenuAction hideAction = new PopMenuAction();
        hideAction.setActionName(getResources().getString(R.string.not_display));
        hideAction.setWeight(800);
        hideAction.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int index, Object data) {
                ConversationInfo conversationInfo = (ConversationInfo) data;
                if (conversationInfo.isMarkFold()) {
                    mConversationLayout.hideFoldedItem(true);
                } else {
                    mConversationLayout.markConversationHidden(conversationInfo);
                }
            }
        });
        mConversationPopActions.add(hideAction);

        PopMenuAction markUnreadAction = null;
        PopMenuAction deleteAction = null;

        if (!conversationInfo.isMarkFold()) {
            if (conversationInfo.getUnRead() > 0) {
                markUnreadAction = getMarkUnreadPopMenuAction(false);
            } else {
                if (conversationInfo.isMarkUnread()) {
                    markUnreadAction = getMarkUnreadPopMenuAction(false);
                } else {
                    markUnreadAction = getMarkUnreadPopMenuAction(true);
                }
            }

            deleteAction = getDeletePopMenuAction();
            mConversationPopActions.add(markUnreadAction);
            mConversationPopActions.add(deleteAction);
            mConversationPopActions.addAll(addMoreConversationAction(conversationInfo));
        }

        View itemPop = LayoutInflater.from(getActivity()).inflate(R.layout.conversation_pop_menu_layout, null);
        mConversationPopList = itemPop.findViewById(R.id.pop_menu_list);
        mConversationPopList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                PopMenuAction action = mConversationPopActions.get(position);
                if (action.getActionClickListener() != null) {
                    action.getActionClickListener().onActionClick(position, conversationInfo);
                }
                mConversationPopWindow.dismiss();
                restoreConversationItemBackground();
            }
        });
        TUIConversationConfigClassic.ConversationMenuItemDataSource dataSource = TUIConversationConfigClassic.getConversationMenuItemDataSource();
        if (dataSource != null) {
            List<Integer> excludeList = dataSource.conversationShouldHideItemsInMoreMenu(conversationInfo);
            if (excludeList != null && !excludeList.isEmpty()) {
                if (excludeList.contains(TUIConversationConfigClassic.HIDE)) {
                    mConversationPopActions.remove(hideAction);
                }
                if (excludeList.contains(TUIConversationConfigClassic.DELETE)) {
                    mConversationPopActions.remove(deleteAction);
                }
            }
            List<PopMenuAction> conversationPopMenuItems = dataSource.conversationShouldAddNewItemsToMoreMenu(conversationInfo);
            if (conversationPopMenuItems != null && !conversationPopMenuItems.isEmpty()) {
                mConversationPopActions.addAll(conversationPopMenuItems);
            }
        }
        Collections.sort(mConversationPopActions, new Comparator<PopMenuAction>() {
            @Override
            public int compare(PopMenuAction o1, PopMenuAction o2) {
                return o2.getWeight() - o1.getWeight();
            }
        });
        mConversationPopAdapter = new PopDialogAdapter();
        mConversationPopList.setAdapter(mConversationPopAdapter);
        mConversationPopAdapter.setDataSource(mConversationPopActions);
        mConversationPopWindow = new PopupWindow(itemPop, WindowManager.LayoutParams.WRAP_CONTENT, WindowManager.LayoutParams.WRAP_CONTENT);
        mConversationPopWindow.setBackgroundDrawable(new ColorDrawable());
        mConversationPopWindow.setOutsideTouchable(true);
        int width = ConversationUtils.getListUnspecifiedWidth(mConversationPopAdapter, mConversationPopList);
        mConversationPopWindow.setWidth(width);
        mConversationPopWindow.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                restoreConversationItemBackground();
            }
        });
        int x = view.getWidth() / 2;
        if (LayoutUtil.isRTL()) {
            x = -x;
        }
        int y = -view.getHeight() / 3;
        int popHeight = ScreenUtil.dip2px(45) * 3;
        if (y + popHeight + view.getY() + view.getHeight() > mConversationLayout.getBottom()) {
            y = y - popHeight;
        }
        mConversationPopWindow.showAsDropDown(view, x, y, Gravity.TOP | Gravity.START);
    }

    private void startFoldedConversationActivity() {
        Intent intent = new Intent(getActivity(), TUIFoldedConversationActivity.class);
        startActivity(intent);
    }

    protected List<PopMenuAction> addMoreConversationAction(ConversationInfo conversationInfo) {
        List<PopMenuAction> settingsList = new ArrayList<>();
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIConversation.CONTEXT, getContext());
        param.put(TUIConstants.TUIConversation.KEY_CONVERSATION_INFO, conversationInfo);
        List<TUIExtensionInfo> extensionList = TUICore.getExtensionList(TUIConstants.TUIConversation.Extension.ConversationPopMenu.CLASSIC_EXTENSION_ID, param);
        for (TUIExtensionInfo extensionInfo : extensionList) {
            String text = extensionInfo.getText();
            if (!TextUtils.isEmpty(text)) {
                PopMenuAction action = new PopMenuAction();
                action.setActionClickListener(new PopActionClickListener() {
                    @Override
                    public void onActionClick(int index, Object data) {
                        TUIExtensionEventListener listener = extensionInfo.getExtensionListener();
                        if (listener != null) {
                            listener.onClicked(null);
                        }
                    }
                });
                action.setWeight(extensionInfo.getWeight());
                action.setActionName(text);
                settingsList.add(action);
            }
        }

        return settingsList;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        TUIConversationLog.d(TAG, "onDestroy");
        if (presenter != null) {
            presenter.destroy();
            presenter = null;
        }
    }
}
