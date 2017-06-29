package com.mapswithme.maps.taxi;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v4.view.PagerAdapter;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.mapswithme.maps.R;
import com.mapswithme.maps.routing.RoutingController;

import java.util.List;

public class TaxiAdapter extends PagerAdapter
{
  @NonNull
  private final Context mContext;
  @NonNull
  private final List<TaxiInfo.Product> mProducts;
  @TaxiManager.TaxiType
  private final int mType;

  public TaxiAdapter(@NonNull Context context, @TaxiManager.TaxiType int type,
                     @NonNull List<TaxiInfo.Product> products)
  {
    mContext = context;
    mType = type;
    mProducts = products;
  }

  @Override
  public int getCount()
  {
    return mProducts.size();
  }

  @Override
  public boolean isViewFromObject(View view, Object object)
  {
    return view == object;
  }

  @Override
  public Object instantiateItem(ViewGroup container, int position)
  {
    TaxiInfo.Product product = mProducts.get(position);

    View v = LayoutInflater.from(mContext).inflate(R.layout.taxi_pager_item, container, false);
    TextView name = (TextView) v.findViewById(R.id.product_name);
    // We ignore all Yandex.Taxi product names until they do support of passing product parameters
    // to their app vie deeplink.
    if (mType == TaxiManager.PROVIDER_YANDEX)
      name.setText(R.string.yandex_taxi_title);
    else
      name.setText(product.getName());
    TextView timeAndPrice = (TextView) v.findViewById(R.id.arrival_time_price);
    int time = Integer.parseInt(product.getTime());
    CharSequence waitTime = RoutingController.formatRoutingTime(mContext, time, R.dimen.text_size_body_3);
    timeAndPrice.setText(mContext.getString(R.string.taxi_wait, waitTime + " • " + product.getPrice()));
    container.addView(v, 0);
    return v;
  }

  @Override
  public void destroyItem(ViewGroup container, int position, Object object)
  {
    container.removeView((View) object);
  }
}
