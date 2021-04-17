package com.mapswithme.maps.bookmarks;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StyleRes;
import androidx.fragment.app.Fragment;

import com.mapswithme.maps.R;
import com.mapswithme.maps.base.BaseToolbarActivity;
import com.mapswithme.maps.bookmarks.data.BookmarkCategory;
import com.mapswithme.maps.bookmarks.data.BookmarkManager;
import com.mapswithme.util.ThemeUtils;

public class BookmarkCategoriesActivity extends BaseToolbarActivity
{
  @CallSuper
  @Override
  public void onResume()
  {
    super.onResume();

    // Disable all notifications in BM on appearance of this activity.
    // It allows to significantly improve performance in case of bookmarks
    // modification. All notifications will be sent on activity's disappearance.
    BookmarkManager.INSTANCE.setNotificationsEnabled(false);
  }

  @CallSuper
  @Override
  public void onPause()
  {
    // Allow to send all notifications in BM.
    BookmarkManager.INSTANCE.setNotificationsEnabled(true);

    super.onPause();
  }

  @Override
  @StyleRes
  public int getThemeResourceId(@NonNull String theme)
  {
    return ThemeUtils.getWindowBgThemeResourceId(getApplicationContext(), theme);
  }

  @Override
  protected Class<? extends Fragment> getFragmentClass()
  {
    return BookmarkCategoriesFragment.class;
  }

  @Override
  protected int getContentLayoutResId()
  {
    return R.layout.bookmarks_activity;
  }

  public static void start(@NonNull Context context)
  {
    context.startActivity(new Intent(context, BookmarkCategoriesActivity.class));
  }

  public static void start(@NonNull Activity context, @Nullable BookmarkCategory category)
  {
    Bundle args = new Bundle();
    args.putParcelable(BookmarksListFragment.EXTRA_CATEGORY, category);
    Intent intent = new Intent(context, BookmarkCategoriesActivity.class);
    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP).putExtras(args);
    context.startActivity(intent);
  }

  public static void start(@NonNull Activity context)
  {
    start(context, null);
  }
}
