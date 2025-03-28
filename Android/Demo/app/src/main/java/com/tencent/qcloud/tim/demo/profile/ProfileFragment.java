package com.tencent.qcloud.tim.demo.profile;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.utils.ProfileUtil;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;

public class ProfileFragment extends Fragment {
    private View mBaseView;
    private ProfileLayout mProfileLayout;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.profile_fragment, container, false);
        initView();
        return mBaseView;
    }

    @Override
    public void onResume() {
        super.onResume();
        if (mProfileLayout != null) {
            mProfileLayout.initUI();
        }
    }

    private void initView() {
        mProfileLayout = mBaseView.findViewById(R.id.profile_view);
        mBaseView.findViewById(R.id.logout_btn).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                new TUIKitDialog(getActivity())
                    .builder()
                    .setCancelable(true)
                    .setCancelOutside(true)
                    .setTitle(getString(R.string.logout_tip))
                    .setDialogWidth(0.75f)
                    .setPositiveButton(getString(com.tencent.qcloud.tuicore.R.string.sure),
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                TUILogin.logout(new TUICallback() {
                                    @Override
                                    public void onSuccess() {
                                        ProfileUtil.onLogoutSuccess(getActivity());
                                    }

                                    @Override
                                    public void onError(int code, String desc) {
                                        ToastUtil.toastLongMessage("logout fail: " + code + "=" + desc);
                                    }
                                });
                            }
                        })
                    .setNegativeButton(getString(com.tencent.qcloud.tuicore.R.string.cancel),
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {}
                        })
                    .show();
            }
        });
    }

    public void reloadData() {
        if (mProfileLayout != null) {
            mProfileLayout.loadUserInfo();
        }
    }
}
