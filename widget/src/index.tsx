import React from "react";

interface AnimWidgetProps {}

export default function AnimWidget(props: AnimWidgetProps) {
  const content = JSON.stringify(props);
  return <div>{content}</div>;
}
