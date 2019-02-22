---
title: 一行代码学安卓
date: 2017-09-26 15:41:54
categories:
	- Programming
	- Android
tags:
    - Programming
	- Android
    - RecyclerView
---

## RecyclerView

{%codeblock MainActivity.onCreate lang:java%}
RecyclerView recyclerView = findViewById(R.id.recycle);
recyclerView.setLayoutManager(new LinearLayoutManager(this)); // 必须设置布局管理器，否则不显示
recyclerView.setAdapter(new RecyclerView.Adapter() {
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        // 每个列表项使用android.R.layout.simple_list_item_1填充
        return new RecyclerView.ViewHolder(LayoutInflater.from(parent.getContext()).inflate(android.R.layout.simple_list_item_1, parent, false)) {
            // ViewHolder是抽象类，必须实现，当然，可以是空实现
        };
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        // 将每个列表项的文本依次设置1、2、3...
        ((TextView) holder.itemView.findViewById(android.R.id.text1)).setText(String.valueOf(position));
    }

    @Override
    public int getItemCount() {
        // 将列表长度设为50
        return 50;
    }
});
{%endcodeblock%}

<!--more-->

<img src="/images/20170926-android-in-on-line-1.png" alt="RecyclerView" width="500px" />

